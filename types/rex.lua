---@meta rex
-- Types for the parts of the Rex Lua API this configuration uses.
-- Source: https://www.superlogical.com/rex/docs/reference/lua
-- rex.bind and rex.client.queue are typed per action in actions.lua.

---@alias rex.Key string A key ("cmd+shift+d"), a sequence ("ctrl+b>c"), or either behind a mode ("resize/left").

---@class rex.Context
---@field session_id? string
---@field block_id? string
---@field client_id? string
---@field origin? "key"|"palette"|"cli"|"api"|"script"|"timer"
---@field server? string

---@class rex.KeyEvent
---@field keybinding string The key that was pressed.
---@field prefix? string[] For a sequence, the keys before it.

--- Return true to mark the key handled; otherwise it falls through to the terminal.
---@alias rex.KeyFn fun(ctx: rex.Context, ev: rex.KeyEvent): boolean?

---@alias rex.ArgType
---| "string" | "number" | "integer" | "boolean" | "object" | "array" | "any"
---| "string?" | "number?" | "integer?" | "boolean?" | "object?" | "array?" | "any?"

---@class rex.ActionSpec
---@field name rex.LocalAction Lowercase letters, digits, and underscores.
---@field title string Shown in the command palette.
---@field run fun(ctx: rex.Context, args: table): any
---@field description? string
---@field category? string Palette group. Defaults to "Actions".
---@field keywords? string
---@field args? table<string, rex.ArgType>
---@field repeats? boolean Run again while the key is held.

---@class rex.Binding
---@field key string
---@field mode? string
---@field action? string
---@field fn? rex.KeyFn
---@field args? table
---@field source string

---@class rex
---@field client rex.client
---@field block rex.block
rex = {}

---@class rex.client
rex.client = {}

---@class rex.block
rex.block = {}

---@param spec rex.ActionSpec
function rex.action(spec) end

---@param key rex.Key
---@param target? string|rex.KeyFn
---@return integer removed
---@overload fun(mode: { mode: string }): integer
---@overload fun(binding: rex.Binding): integer
function rex.unbind(key, target) end

---@param name string
---@param options? { exclusive?: boolean }
function rex.mode(name, options) end

---@param filter? { key?: string, mode?: string, action?: string }
---@return rex.Binding[]
function rex.bindings(filter) end

--- Calls a method on a block. block_id defaults to the current block.
---@param creator string
---@param method string
---@param args? table
---@return table? result
---@return string? err
function rex.block.call(creator, method, args) end

---@class rex.ExecResult
---@field code integer Exit status, or -1 if a signal ended the command.
---@field signal? string
---@field stdout string
---@field stderr string
---@field timed_out boolean
---@field ok boolean True if code is 0 and the command didn't time out.

---@class rex.ExecOptions
---@field cwd? string
---@field env? table<string, string|false>
---@field clear_env? boolean
---@field stdin? string
---@field timeout? number Seconds.
---@field stdout? false
---@field stderr? false

---@class rex.ExecStartOptions
---@field cwd? string
---@field env? table<string, string|false>
---@field clear_env? boolean
---@field stdin? string|true true keeps standard input open for h:write.
---@field timeout? number Seconds.
---@field stdout? false|fun(data: string)
---@field stderr? false|fun(data: string)
---@field detach? boolean true lets the command outlive the work that started it.

---@class rex.ExecHandle
---@field pid integer
local ExecHandle = {}
---@param seconds? number
---@return rex.ExecResult? result
---@return string? err "timeout" if seconds passed first.
function ExecHandle:wait(seconds) end
---@param data string
---@return true? ok
---@return string? err
function ExecHandle:write(data) end
function ExecHandle:close_stdin() end
---@param signal? string|integer SIGTERM by default.
function ExecHandle:kill(signal) end
---@return boolean
function ExecHandle:running() end

--- Runs a command without a shell. Returns nil and an error only if it never ran.
---@class rex.execlib
---@overload fun(argv: string[], opts?: rex.ExecOptions): rex.ExecResult?, string?
rex.exec = {}

--- Starts a command and returns without waiting.
---@param argv string[]
---@param opts? rex.ExecStartOptions
---@return rex.ExecHandle? handle
---@return string? err
function rex.exec.start(argv, opts) end

---@class rex.Timer
local Timer = {}
function Timer:cancel() end
---@return boolean
function Timer:active() end

--- Script only (nil in the config file).
---@param seconds number
---@param fn fun(ctx: rex.Context)
---@return rex.Timer
function rex.after(seconds, fn) end

--- Script only (nil in the config file).
---@param seconds number
---@param fn fun(ctx: rex.Context)
---@return rex.Timer
function rex.every(seconds, fn) end

--- Script only. Calls fn for each event; register while the script first runs.
---@param event string
---@param fn fun(ctx: rex.Context, ev: table)
function rex.on(event, fn) end

--- Script only. Ends the script; rex do exits with code.
---@param code? integer
function rex.stop(code) end

--- Script only: the KEY=VALUE arguments given to rex do. nil in the config file.
---@type table<string, any>?
rex.args = nil

--- Calls any server method by its full name.
---@param method string
---@param args? table
---@return table? result
---@return string? err
function rex.call(method, args) end

---@class rex.session
rex.session = {}

--- Changes which session a script hears events from, and lets it call that session.
---@param args { session_id: string }
---@return table? result
---@return string? err
function rex.session.attach(args) end

---@alias rex.StatusState "idle"|"working"|"done"|"blocked"|"error"

--- A record from a terminal's program_status method (OSC 7501).
---@class rex.StatusRecord
---@field state rex.StatusState Treat an unknown value as "idle".
---@field updated_at string
---@field id? string
---@field app? string
---@field effective_app? string
---@field kind? "permission"|"question"|"auth"
---@field msg? string
---@field title? string
---@field progress? integer
---@field owner? { pid: integer, name: string }

---@param level "debug"|"info"|"warn"|"error"
---@param message string
---@overload fun(message: string)
function rex.log(level, message) end

---@class rex.json
rex.json = {}

---@param value any
---@param opts? { indent?: boolean }
---@return string? text
---@return string? err
function rex.json.encode(value, opts) end

---@param text string
---@return any value
---@return string? err
function rex.json.decode(text) end
