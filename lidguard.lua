-- Lid guard: while an agent is working, a closed lid doesn't put the Mac to sleep.
--
-- One file, two roles:
--   * init.lua requires it and calls start(), which launches the guard as a child of the Rex server.
--   * The guard is this file run with `rex do lidguard.lua --all`. It watches every terminal's
--     program status (OSC 7501) and drives `pmset disablesleep` through a small state machine.
--
-- Try it without touching pmset: rex do ~/.config/rex/lidguard.lua --all dry_run=true
-- Log: ~/Library/Logs/rex-lidguard.log
--
-- Install (the guard needs a sudoers rule for exactly three pmset commands, see lidguard.sudoers):
--   cd ~/.config/rex && sudo visudo -cf lidguard.sudoers && sudo install -m 0440 -o root -g wheel lidguard.sudoers /etc/sudoers.d/rex-lidguard
--   Then keep `require("lidguard").start()` in init.lua and run: rex config reload
--
-- Uninstall, in this order (the watchdog needs the sudoers rule to restore sleep):
--   1. Delete `require("lidguard").start()` from init.lua, then run: rex config reload
--   2. Stop the guard; its watchdog sets disablesleep back to 0:
--        kill "$(cat ~/Library/Application\ Support/rex/lidguard.pid)"
--   3. Check that sleep is normal; SleepDisabled must be 0:
--        pmset -g | grep SleepDisabled      (if it shows 1: sudo pmset -a disablesleep 0)
--   4. Remove the sudoers rule: sudo rm /etc/sudoers.d/rex-lidguard
--   5. Optional: rm ~/.config/rex/lidguard.lua ~/.config/rex/lidguard.sudoers \
--        ~/Library/Logs/rex-lidguard.log ~/Library/Application\ Support/rex/lidguard.pid

local HOME = assert(os.getenv("HOME"))
local CONFIG_DIR = (os.getenv("XDG_CONFIG_HOME") or (HOME .. "/.config")) .. "/rex"
local REX = HOME .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local TERMINAL = "com.superlogical.terminal"

local SETTINGS = {
  grace_seconds = 60,       -- agents must stay quiet this long before the guard lets go
  low_battery_percent = 10, -- at or below this, on battery, the guard lets go at once
  tick_seconds = 15,        -- how often battery, lid, and watchdog are checked
  pid_path = HOME .. "/Library/Application Support/rex/lidguard.pid",
  status_path = HOME .. "/Library/Application Support/rex/lidguard.json",
  log_path = HOME .. "/Library/Logs/rex-lidguard.log",
}

---@class lidguard.Released
---@field mode "released"

---@class lidguard.Holding
---@field mode "holding"

---@class lidguard.Draining
---@field mode "draining"
---@field quiet_since integer os.time() when the last agent stopped working.

---@alias lidguard.State lidguard.Released | lidguard.Holding | lidguard.Draining

---@class lidguard.Snapshot
---@field agents string[] The app of every status record in the `working` state.
---@field battery_low boolean On battery, at or below SETTINGS.low_battery_percent.
---@field lid_closed boolean

---@type lidguard.Released
local RELEASED = { mode = "released" }
---@type lidguard.Holding
local HOLDING = { mode = "holding" }

---@param now integer
---@return lidguard.Draining
local function draining(now)
  return { mode = "draining", quiet_since = now }
end

---------------------------------------------------------------------------
-- Shared helpers
---------------------------------------------------------------------------

---@param argv string[]
---@return string stdout Empty when the command failed.
local function output(argv)
  local result = rex.exec(argv, { timeout = 5 })
  return (result and result.ok) and result.stdout or ""
end

--- Whether pid is a live guard, not just any process that reused the number.
---@param pid integer?
---@return boolean
local function is_guard(pid)
  if pid == nil then return false end
  return output({ "/bin/ps", "-o", "command=", "-p", tostring(pid) }):find("lidguard.lua", 1, true) ~= nil
end

---------------------------------------------------------------------------
-- Launching and status (config file role)
---------------------------------------------------------------------------

--- Starts the guard as a detached child of the Rex server. Safe to call on every load:
--- a new guard replaces the old one, and a copy started by `rex config check` exits.
local function start()
  local command = 'exec "$0" do "$1" --all --autostart=false launched=true >>"$2" 2>&1'
  local script = CONFIG_DIR .. "/lidguard.lua"
  local _, err = rex.exec.start({ "/bin/sh", "-c", command, REX, script, SETTINGS.log_path }, { detach = true })
  if err ~= nil then rex.log("warn", "lidguard: " .. err) end
end

--- The guard's last saved status, plus whether it is still running.
---@return table
local function status()
  local file = io.open(SETTINGS.status_path, "r")
  local saved = file and rex.json.decode(file:read("*a")) or {}
  if file then file:close() end
  saved.running = is_guard(saved.pid)
  return saved
end

---------------------------------------------------------------------------
-- Commands and sensors (guard role)
---------------------------------------------------------------------------

local DRY_RUN = false

---@param format string
local function log(format, ...)
  local line = os.date("%Y-%m-%d %H:%M:%S") .. " " .. string.format(format, ...) .. "\n"
  local file = io.open(SETTINGS.log_path, "a")
  if file then file:write(line); file:close() end
  if DRY_RUN then io.write(line) end
end

--- Runs `sudo -n pmset ...`. In a dry run, only logs it.
local function pmset(...)
  local argv = { "/usr/bin/sudo", "-n", "/usr/bin/pmset", ... }
  if DRY_RUN then return log("dry run: %s", table.concat(argv, " ")) end
  local result, err = rex.exec(argv, { timeout = 10 })
  if result == nil then
    log("pmset %s did not run: %s", table.concat({ ... }, " "), err)
  elseif not result.ok then
    log("pmset %s failed: %s", table.concat({ ... }, " "), result.stderr)
  end
end

local simulated_sleep_disabled = false

---@return boolean
local function sleep_disabled()
  if DRY_RUN then return simulated_sleep_disabled end
  return output({ "/usr/bin/pmset", "-g" }):match("SleepDisabled%s+(%d)") == "1"
end

---@param on boolean
local function set_sleep_disabled(on)
  simulated_sleep_disabled = on
  pmset("-a", "disablesleep", on and "1" or "0")
end

---@return boolean
local function battery_low()
  local text = output({ "/usr/bin/pmset", "-g", "batt" })
  local percent = tonumber(text:match("(%d+)%%"))
  local on_battery = text:find("'Battery Power'", 1, true) ~= nil
  return on_battery and percent ~= nil and percent <= SETTINGS.low_battery_percent
end

---@return boolean
local function lid_closed()
  local text = output({ "/usr/sbin/ioreg", "-r", "-k", "AppleClamshellState", "-d", "1" })
  return text:match('"AppleClamshellState" = (%a+)') == "Yes"
end

---------------------------------------------------------------------------
-- Agents
---------------------------------------------------------------------------

---@param session_id string
---@param block_id string
---@return rex.StatusRecord[]
local function status_records(session_id, block_id)
  local result = rex.call("block.method", { session_id = session_id, block_id = block_id, method = "program_status" })
  return result and result.records or {}
end

---@param session_id string
---@return string[] block_ids The session's terminal blocks.
local function terminal_blocks(session_id)
  rex.session.attach{ session_id = session_id }
  local list = rex.call("session.list_blocks", { session_id = session_id })
  local ids = {}
  for _, block in ipairs(list and list.blocks or {}) do
    if block.creator_name == TERMINAL then table.insert(ids, block.block_id) end
  end
  return ids
end

---@return string[] agents The app of every `working` record, in every session.
local function working_agents()
  local list = rex.call("session.list")
  local agents = {}
  for _, session in ipairs(list and list.sessions or {}) do
    for _, block_id in ipairs(terminal_blocks(session.session_id)) do
      for _, record in ipairs(status_records(session.session_id, block_id)) do
        if record.state == "working" then table.insert(agents, record.effective_app or "unknown") end
      end
    end
  end
  return agents
end

---@return lidguard.Snapshot
local function snapshot()
  return { agents = working_agents(), battery_low = battery_low(), lid_closed = lid_closed() }
end

---------------------------------------------------------------------------
-- State machine
---------------------------------------------------------------------------

---@type table<string, fun(state: lidguard.State, snap: lidguard.Snapshot, now: integer): lidguard.State>
local TRANSITIONS = {
  released = function(_, snap)
    return #snap.agents > 0 and HOLDING or RELEASED
  end,
  holding = function(_, snap, now)
    return #snap.agents > 0 and HOLDING or draining(now)
  end,
  draining = function(state, snap, now)
    if #snap.agents > 0 then return HOLDING end
    ---@cast state lidguard.Draining
    return now - state.quiet_since >= SETTINGS.grace_seconds and RELEASED or state
  end,
}

---@param state lidguard.State
---@param snap lidguard.Snapshot
---@param now integer
---@return lidguard.State
local function next_state(state, snap, now)
  if snap.battery_low then return RELEASED end
  return TRANSITIONS[state.mode](state, snap, now)
end

---@param state lidguard.State
---@return boolean
local function holds(state)
  return state.mode ~= "released"
end

--- Makes the system match the new state: the flag follows the state, and letting go
--- with the lid closed puts the Mac to sleep.
---@param old lidguard.State
---@param new lidguard.State
---@param snap lidguard.Snapshot
local function apply(old, new, snap)
  if old.mode ~= new.mode then
    log("%s -> %s (agents: %s)", old.mode, new.mode, table.concat(snap.agents, ", "))
  end
  if holds(new) ~= sleep_disabled() then set_sleep_disabled(holds(new)) end
  if holds(old) and not holds(new) and snap.lid_closed then pmset("sleepnow") end
end

--- Saves what the guard sees, for the lidguard_status action to read.
---@param pid integer
---@param state lidguard.State
---@param snap lidguard.Snapshot
local function save_status(pid, state, snap)
  local releases_at = nil ---@type string?
  if state.mode == "draining" then
    ---@cast state lidguard.Draining
    releases_at = os.date("%H:%M:%S", state.quiet_since + SETTINGS.grace_seconds) --[[@as string]]
  end
  local text = rex.json.encode({
    pid = pid,
    mode = state.mode,
    agents = table.concat(snap.agents, ", "),
    releases_at = releases_at,
    sleep_disabled = sleep_disabled(),
    lid_closed = snap.lid_closed,
    battery_low = snap.battery_low,
    updated_at = os.date("%Y-%m-%d %H:%M:%S"),
  }, { indent = true })
  local file = io.open(SETTINGS.status_path, "w")
  if file and text then file:write(text, "\n"); file:close() end
end

---------------------------------------------------------------------------
-- Process: identity, takeover, watchdog
---------------------------------------------------------------------------

---@return integer pid This guard's process ID.
local function own_pid()
  return assert(tonumber(output({ "/bin/sh", "-c", "echo $PPID" })))
end

---@return boolean
local function parent_is_rex_server()
  local parent = output({ "/bin/sh", "-c", 'ps -o command= -p "$(ps -o ppid= -p $PPID)"' })
  return parent:find(" server run", 1, true) ~= nil
end

--- Records this guard in the PID file, then stops the guard it replaces.
---@param pid integer
local function take_over(pid)
  local file = io.open(SETTINGS.pid_path, "r")
  local old = file and tonumber(file:read("*l"))
  if file then file:close() end
  local out = assert(io.open(SETTINGS.pid_path, "w"))
  out:write(pid, "\n"); out:close()
  if old ~= pid and is_guard(old) then
    ---@cast old integer
    rex.exec({ "/bin/kill", tostring(old) })
    log("replaced guard %d", old)
  end
end

-- Waits for the guard's end of the pipe to close, which happens however the guard dies,
-- kill -9 included. Restores sleep unless a newer guard has taken over the PID file.
-- Arguments: $1 PID file, $2 guard PID, $3 log file, $4 sudo prefix.
local WATCHDOG = [[
while read -r _; do :; done
[ "$(cat "$1" 2>/dev/null)" = "$2" ] || exit 0
echo "$(date '+%Y-%m-%d %H:%M:%S') guard $2 ended; restoring sleep" >> "$3"
$4 /usr/bin/pmset -a disablesleep 0 >> "$3" 2>&1
]]

---@param pid integer
---@return rex.ExecHandle
local function start_watchdog(pid)
  local sudo = DRY_RUN and "echo dry run: sudo -n" or "/usr/bin/sudo -n"
  local argv = { "/bin/sh", "-c", WATCHDOG, "lidguard-watchdog", SETTINGS.pid_path, tostring(pid), SETTINGS.log_path, sudo }
  -- Output goes to the log, never to Rex: after the guard dies, a write to its pipe would kill the watchdog.
  return assert(rex.exec.start(argv, { stdin = true, detach = true, stdout = false, stderr = false }))
end

---------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------

---@param args table<string, any>
local function main(args)
  DRY_RUN = args.dry_run == true
  if args.launched == true and not parent_is_rex_server() then rex.stop(0) end

  local pid = own_pid()
  take_over(pid)
  local watchdog = start_watchdog(pid)

  ---@type lidguard.State
  local state = sleep_disabled() and draining(os.time()) or RELEASED
  log("guard %d started%s in %s", pid, DRY_RUN and " (dry run)" or "", state.mode)

  local function evaluate()
    if not watchdog:running() then watchdog = start_watchdog(pid) end
    local snap = snapshot()
    local new = next_state(state, snap, os.time())
    apply(state, new, snap)
    state = new
    save_status(pid, state, snap)
  end

  local pending ---@type rex.Timer?
  local function soon()
    if pending then pending:cancel() end
    pending = rex.after(1, evaluate)
  end

  for _, event in ipairs({ "terminal.program_status_changed", "terminal.program_status_removed", "block_closed", "session_destroyed" }) do
    rex.on(event, soon)
  end
  rex.every(SETTINGS.tick_seconds, evaluate)
  evaluate()
end

if rex.args == nil then return { start = start, status = status } end -- required from the config file
main(rex.args)
