---@meta rex.builtin_actions
-- Generated from the actions Rex 0.1.0 (1408) offers (`rex api call client.inspect`, `rex actions --json`).
-- Regenerate with types/gen_actions.py after a Rex update adds or changes actions.

---@alias rex.ClientNoArgAction
---| "client.window.new" # New Window
---| "client.window.close" # Close Window
---| "client.window.fullscreen.toggle" # Toggle Full Screen
---| "client.close" # Close
---| "client.palette.toggle" # Command Palette…
---| "client.settings" # Settings…
---| "client.diagnostics" # Rex Diagnostics
---| "client.onboarding" # Open Onboarding Session…
---| "client.permissions" # Grant System Permissions…
---| "client.version.copy" # Copy Version Info
---| "client.debug.copy" # Copy Debug Info
---| "client.pair_device" # Pair Device with QR Code…
---| "client.update.accept" # Install Update
---| "client.notice.dismiss" # Dismiss Notice
---| "client.shortcuts.edit" # Change Shortcut…
---| "client.agents.setup" # Install Rex for Agents
---| "client.server.restart" # Restart Server…
---| "session.new" # New Session
---| "session.switch" # Change Session…
---| "session.next" # Next Session
---| "session.previous" # Previous Session
---| "session.rename" # Rename Session
---| "session.close" # Close Session
---| "session.refresh" # Refresh Sessions
---| "session.open_on_web" # Open Session on Web…
---| "client.host.switch" # Switch Host
---| "client.host.add" # Add Remote Host…
---| "client.host.remove" # Remove Host…
---| "client.tab.new" # New Tab
---| "client.tab.close" # Close Tab
---| "client.tab.rename" # Rename Tab
---| "client.tab.next" # Show Next Tab
---| "client.tab.previous" # Show Previous Tab
---| "client.tab.move.backward" # Move Tab Backward
---| "client.tab.move.forward" # Move Tab Forward
---| "client.tab.move_to_new_window" # Move Tab to New Window
---| "pane.split.left" # Split Pane Left
---| "pane.split.right" # Split Pane Right
---| "pane.split.up" # Split Pane Up
---| "pane.split.down" # Split Pane Down
---| "pane.split.auto" # Split Pane Best Fit
---| "pane.focus.left" # Focus Pane Left
---| "pane.focus.right" # Focus Pane Right
---| "pane.focus.up" # Focus Pane Up
---| "pane.focus.down" # Focus Pane Down
---| "pane.focus_next" # Focus Next Pane
---| "pane.focus_previous" # Focus Previous Pane
---| "pane.move.left" # Move Pane Left
---| "pane.move.right" # Move Pane Right
---| "pane.move.up" # Move Pane Up
---| "pane.move.down" # Move Pane Down
---| "pane.zoom" # Zoom Pane
---| "pane.close" # Close Pane
---| "pane.balance" # Balance Splits
---| "pane.move_to_new_tab" # Move Pane to New Tab
---| "pane.move_to_tab" # Move Pane to Tab…
---| "pane.go_to_directory" # Go to Directory…
---| "pane.insert_path" # Insert Path…
---| "pane.copy_id" # Copy Pane ID
---| "client.key.forward" # Send Key to Server
---| "client.prompt.previous" # Jump to Previous Prompt
---| "client.prompt.next" # Jump to Next Prompt
---| "client.mode.exit" # Exit Mode
---| "client.mode.exit_all" # Exit All Modes
---| "client.find.open" # Find…
---| "client.find.next" # Find Next
---| "client.find.previous" # Find Previous
---| "client.font.increase" # Increase Font Size
---| "client.font.decrease" # Decrease Font Size
---| "client.font.reset" # Reset Font Size
---| "client.sidebar.toggle" # Toggle Sidebar
---| "client.sidebar.activity.toggle" # Toggle Activity
---| "client.tab_style.toggle" # Toggle Tab Style
---| "client.config.copy_path" # Copy Config File Path
---| "client.config.reload" # Reload Config

---@alias rex.BlockNoArgAction
---| "com.superlogical.terminal.clear" # Clear Terminal
---| "com.superlogical.terminal.reset" # Reset Terminal

---@class rex.args.session_select
---@field session_id string The identifier that the session's server assigned.
---@field window_id? string A window in the session to show. If omitted, the session opens as usual.

---@class rex.args.client_tab_goto
---@field index integer The tab to show. Tabs count from 1, and -1 means the last tab.

---@class rex.args.client_tab_move
---@field direction "backward"|"forward"

---@class rex.args.pane_split
---@field direction "right"|"down"|"left"|"up"|"auto"

---@class rex.args.pane_focus
---@field direction "left"|"right"|"up"|"down"
---@field wrap? boolean Continue from the opposite edge of the layout when no pane lies in the direction. The default is true.

---@class rex.args.pane_move
---@field direction "left"|"right"|"up"|"down"

---@class rex.args.pane_resize
---@field amount? number How far to move the divider, as a percentage of the split it divides. The default is 5.
---@field direction "left"|"right"|"up"|"down"

---@class rex.args.pane_send_key
---@field key string The key to send, written the way a key binding is, such as "ctrl+u".

---@class rex.args.client_mode_enter
---@field name string The mode to enter, as the configuration names it.
---@field once? boolean Leave the mode after one of its own keys performs. The default is false.

---@class rex.args.client_theme_change
---@field name? string Theme name or ID to fuzzy-match. Omit to open the theme picker.

---@class rex.args.client_theme_import
---@field path string Absolute path of a Ghostty theme or iTerm color file on this machine.

---@class rex.args.client_appearance_switch_mode
---@field mode "light"|"dark"|"toggle" Use light or dark appearance, or toggle the currently visible appearance.

---@class rex.args.com_superlogical_onboarding_set_step
---@field step string The step to move to. Empty means the first step.

---@class rex.args.com_superlogical_onboarding_state

---@class rex.args.com_superlogical_terminal_blob_read
---@field id? integer The result to read, from the reply or event that named it, such as the id in a format reply or a selection_copied event. Zero or left out reads the newest result, whatever produced it. If the server no longer has the result, the call fails with not_found.
---@field offset? integer Where to start reading, in bytes from the start of the result. To read the next part, add the length in bytes of the data you received. Must not be negative.
---@field max_bytes? integer The most bytes of data to return, measured once it is encoded as a JSON string. Zero or left out means 49152 (48 KiB), and values above 983040 (960 KiB) are lowered to that. Must not be negative.

---@class rex.args.com_superlogical_terminal_clipboard_read
---@field id? integer The copy to read, from a clipboard_written event or an earlier reply. Zero or left out reads the newest copy. If the server no longer has the copy, the call fails with not_found.
---@field offset? integer Where to start reading, in bytes from the start of the text. To read the next part, add the length in bytes of the data you received. Must not be negative.
---@field max_bytes? integer The most bytes of data to return, measured once it is encoded as a JSON string. Zero or left out means 49152 (48 KiB), and values above 983040 (960 KiB) are lowered to that. Must not be negative.

---@class rex.args.com_superlogical_terminal_format
---@field format? string The format to return: 'text' for plain text, 'html' for HTML with inline styles, or 'vt' for escape sequences that redraw the screen with its colors and styles. Defaults to 'text'.
---@field trim? boolean Remove spaces from the end of each line.
---@field unwrap? boolean Join lines that the terminal wrapped because they were too long, so each line of output is one line the program wrote.
---@field extra_charsets? boolean Include the selected character sets. Only used with the vt format.
---@field extra_cursor? boolean Include the cursor position. Only used with the vt format.
---@field extra_hyperlink? boolean Include the hyperlink in effect at the cursor. Only used with the vt format.
---@field extra_keyboard? boolean Include keyboard modes such as modifyOtherKeys. Only used with the vt format.
---@field extra_kitty_keyboard? boolean Include the state of the Kitty keyboard protocol. Only used with the vt format.
---@field extra_modes? boolean Include terminal modes that differ from their defaults. Only used with the vt format.
---@field extra_palette? boolean Include the color palette. Only used with the vt format.
---@field extra_protection? boolean Include the character protection mode. Only used with the vt format.
---@field extra_pwd? boolean Include the reported working directory. Only used with the vt format.
---@field extra_scrolling_region? boolean Include the scrolling region. Only used with the vt format.
---@field extra_style? boolean Include the text style in effect at the cursor. Only used with the vt format.
---@field extra_tabstops? boolean Include the tab stops. Only used with the vt format.
---@field max_bytes? integer The most bytes of content to return, measured once it is encoded as a JSON string. If more output remains, the reply has an id, and you read the rest with blob_read. Values above 983040 (960 KiB) are lowered to that. Zero or left out returns the whole output in one reply, and the call fails with too_large if the output doesn't fit. Must not be negative.

---@class rex.args.com_superlogical_terminal_input_mode

---@class rex.args.com_superlogical_terminal_list_dir
---@field path? string The directory to list: an absolute path, ~ or a path under ~/ for the home directory, or a path relative to the working directory of the terminal's foreground process. Empty lists that working directory.
---@field prefix? string Keep only entries whose names start with this text, ignoring case. Use it to narrow a listing that came back truncated.
---@field limit? integer The most entries to return. Zero, negative, or left out means 2000.
---@field files? boolean Include entries that aren't directories, such as files, and mark each with file set to true.

---@class rex.args.com_superlogical_terminal_modes

---@class rex.args.com_superlogical_terminal_process

---@class rex.args.com_superlogical_terminal_program_status

---@class rex.args.com_superlogical_terminal_pwd

---@class rex.args.com_superlogical_terminal_resize
---@field columns integer The width in columns, that is, characters per line, from 1 to 65535.
---@field rows integer The height in rows, from 1 to 65535.
---@field cell_width_px? integer The width of one character cell in pixels, from 1 to 65535. Send it together with cell_height_px, or leave both out to keep the current cell size.
---@field cell_height_px? integer The height of one character cell in pixels, from 1 to 65535. Send it together with cell_width_px, or leave both out to keep the current cell size.

---@class rex.args.com_superlogical_terminal_set_theme
---@field foreground? string The default text color, as hex RRGGBB or #RRGGBB, such as #d6deeb. Empty or left out uses the built-in color.
---@field background? string The default background color, as hex RRGGBB or #RRGGBB, such as #011627. Empty or left out uses the built-in color.
---@field cursor? string The cursor color, as hex RRGGBB or #RRGGBB, such as #80a4c2. Empty or left out uses the built-in color.
---@field palette? string[] Changes to the 256-color palette, each written as index=RRGGBB or index=#RRGGBB with an index from 0 to 255, such as 1=#ef5350. Colors not listed keep their built-in values.
---@field scheme? string Whether the theme is 'light' or 'dark', which programs in the terminal can ask for. If empty, the terminal decides from how bright background is, and treats no background as dark.

---@class rex.args.com_superlogical_terminal_size

---@class rex.args.com_superlogical_terminal_title

---@class rex.args.com_superlogical_terminal_write
---@field data string The text to type. It can hold escape sequences for keys that aren't text, such as \u001b[A for the up arrow.

--- Binds a key to an action. Each built-in action is checked against its own arguments.
---@param key rex.Key
---@param action rex.ClientNoArgAction|rex.BlockNoArgAction|rex.LocalAction
---@param args? table
---@overload fun(key: rex.Key, fn: rex.KeyFn)
---@overload fun(key: rex.Key, action: "session.select", args: rex.args.session_select)
---@overload fun(key: rex.Key, action: "client.tab.goto", args: rex.args.client_tab_goto)
---@overload fun(key: rex.Key, action: "client.tab.move", args: rex.args.client_tab_move)
---@overload fun(key: rex.Key, action: "pane.split", args: rex.args.pane_split)
---@overload fun(key: rex.Key, action: "pane.focus", args: rex.args.pane_focus)
---@overload fun(key: rex.Key, action: "pane.move", args: rex.args.pane_move)
---@overload fun(key: rex.Key, action: "pane.resize", args: rex.args.pane_resize)
---@overload fun(key: rex.Key, action: "pane.send_key", args: rex.args.pane_send_key)
---@overload fun(key: rex.Key, action: "client.mode.enter", args: rex.args.client_mode_enter)
---@overload fun(key: rex.Key, action: "client.theme.change", args?: rex.args.client_theme_change)
---@overload fun(key: rex.Key, action: "client.theme.import", args: rex.args.client_theme_import)
---@overload fun(key: rex.Key, action: "client.appearance.switch_mode", args: rex.args.client_appearance_switch_mode)
---@overload fun(key: rex.Key, action: "com.superlogical.onboarding.set_step", args: rex.args.com_superlogical_onboarding_set_step)
---@overload fun(key: rex.Key, action: "com.superlogical.onboarding.state", args?: rex.args.com_superlogical_onboarding_state)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.blob_read", args?: rex.args.com_superlogical_terminal_blob_read)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.clipboard_read", args?: rex.args.com_superlogical_terminal_clipboard_read)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.format", args?: rex.args.com_superlogical_terminal_format)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.input_mode", args?: rex.args.com_superlogical_terminal_input_mode)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.list_dir", args?: rex.args.com_superlogical_terminal_list_dir)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.modes", args?: rex.args.com_superlogical_terminal_modes)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.process", args?: rex.args.com_superlogical_terminal_process)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.program_status", args?: rex.args.com_superlogical_terminal_program_status)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.pwd", args?: rex.args.com_superlogical_terminal_pwd)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.resize", args: rex.args.com_superlogical_terminal_resize)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.set_theme", args?: rex.args.com_superlogical_terminal_set_theme)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.size", args?: rex.args.com_superlogical_terminal_size)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.title", args?: rex.args.com_superlogical_terminal_title)
---@overload fun(key: rex.Key, action: "com.superlogical.terminal.write", args: rex.args.com_superlogical_terminal_write)
function rex.bind(key, action, args) end

--- Asks the client that ran the current action to perform one of its own actions.
---@param action rex.ClientNoArgAction
---@overload fun(action: "session.select", args: rex.args.session_select)
---@overload fun(action: "client.tab.goto", args: rex.args.client_tab_goto)
---@overload fun(action: "client.tab.move", args: rex.args.client_tab_move)
---@overload fun(action: "pane.split", args: rex.args.pane_split)
---@overload fun(action: "pane.focus", args: rex.args.pane_focus)
---@overload fun(action: "pane.move", args: rex.args.pane_move)
---@overload fun(action: "pane.resize", args: rex.args.pane_resize)
---@overload fun(action: "pane.send_key", args: rex.args.pane_send_key)
---@overload fun(action: "client.mode.enter", args: rex.args.client_mode_enter)
---@overload fun(action: "client.theme.change", args?: rex.args.client_theme_change)
---@overload fun(action: "client.theme.import", args: rex.args.client_theme_import)
---@overload fun(action: "client.appearance.switch_mode", args: rex.args.client_appearance_switch_mode)
function rex.client.queue(action) end
