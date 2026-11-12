-- Custom actions. Rex has built-ins for everything else ported from Ghostty.

---@alias rex.LocalAction
---| "use_kanagawa_dragon"
---| "lidguard_status"

local theme = require("theme")

rex.action{
  name = "use_kanagawa_dragon",
  title = "Use Kanagawa Dragon Theme",
  description = "Add the Kanagawa Dragon theme from your Ghostty setup and switch to it.",
  category = "View",
  keywords = "theme colors ghostty kanagawa",
  run = function()
    rex.client.queue("client.theme.import", { path = theme.write(theme.kanagawa_dragon) })
  end,
}

rex.action{
  name = "lidguard_status",
  title = "Show Lid Guard Status",
  description = "Whether a closed lid will put the Mac to sleep, and which agents are keeping it awake.",
  category = "System",
  keywords = "lid sleep battery agents awake",
  run = function()
    return require("lidguard").status()
  end,
}
