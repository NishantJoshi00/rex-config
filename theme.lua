-- Kanagawa Dragon, as set in ~/.config/ghostty/theme.conf.
-- Rex keeps its theme in app settings, so this is written out as a Ghostty
-- theme file and handed to Rex's own theme importer (see actions.lua).

---@alias Hex string "#rrggbb"

---@class Theme
---@field name string Shown in Rex's theme picker.
---@field background Hex
---@field foreground Hex
---@field cursor Hex
---@field cursor_text Hex
---@field selection_background Hex
---@field selection_foreground Hex
---@field palette Hex[] ANSI 0–15, in order.

---@type Theme
local kanagawa_dragon = {
  name = "Kanagawa Dragon",
  background = "#181616",
  foreground = "#c8c093",
  cursor = "#c5c9c5",
  cursor_text = "#1d202f",
  selection_background = "#223249",
  selection_foreground = "#c5c9c5",
  palette = {
    "#0d0c0c", "#c4746e", "#8a9a7b", "#c4b28a", "#8ba4b0", "#a292a3", "#8ea4a2", "#c8c093",
    "#a6a69c", "#e46876", "#87a987", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#c5c9c5",
  },
}

---@param theme Theme
---@return string
local function to_ghostty(theme)
  local lines = {
    "background = " .. theme.background,
    "foreground = " .. theme.foreground,
    "cursor-color = " .. theme.cursor,
    "cursor-text = " .. theme.cursor_text,
    "selection-background = " .. theme.selection_background,
    "selection-foreground = " .. theme.selection_foreground,
  }
  for i, hex in ipairs(theme.palette) do
    lines[#lines + 1] = ("palette = %d=%s"):format(i - 1, hex)
  end
  return table.concat(lines, "\n") .. "\n"
end

--- Writes the theme next to this config and returns the file's path.
---@param theme Theme
---@return string path
local function write(theme)
  local dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex/themes"
  local path = dir .. "/" .. theme.name
  local made = rex.exec({ "mkdir", "-p", dir })
  assert(made and made.ok, "could not create " .. dir)
  local file = assert(io.open(path, "w"))
  file:write(to_ghostty(theme))
  file:close()
  return path
end

return {
  kanagawa_dragon = kanagawa_dragon,
  write = write,
}
