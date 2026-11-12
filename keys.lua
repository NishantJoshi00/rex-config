-- Ported from ~/.config/ghostty/keybinds.conf and config. Ghostty's super is cmd.

-- ===================
-- KEY DISABLES
-- ===================
-- Ghostty: alt+p=ignore. Swallow the key so it never reaches the terminal.
rex.bind("alt+p", function() return true end)

-- ===================
-- WINDOW MANAGEMENT
-- ===================
rex.bind("ctrl+cmd+f", "client.window.fullscreen.toggle")

-- ===================
-- TERMINAL CONTROL
-- ===================
rex.bind("cmd+k", "com.superlogical.terminal.clear")
-- Ghostty: shift+enter=text:\x1b\r
rex.bind("shift+enter", "com.superlogical.terminal.write", { data = "\27\r" })
-- Ghostty's "Terminal Reset" palette entry is built into Rex as "Reset Terminal".

-- ===================
-- INTERFACE ACTIONS
-- ===================
rex.bind("cmd+shift+p", "client.palette.toggle")

-- ===================
-- PANE SPLITTING
-- ===================
rex.bind("cmd+shift+j", "pane.split", { direction = "down" })
rex.bind("cmd+shift+l", "pane.split", { direction = "right" })
rex.bind("cmd+shift+h", "pane.split", { direction = "left" })
rex.bind("cmd+shift+k", "pane.split", { direction = "up" })

-- ===================
-- PANE NAVIGATION
-- ===================
rex.bind("cmd+h", "pane.focus_previous")
rex.bind("cmd+l", "pane.focus_next")
rex.bind("cmd+j", "pane.zoom")
