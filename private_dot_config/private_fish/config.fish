if status is-interactive
    # Commands to run in interactive sessions can go here
end
function fish_greeting
end

set -gx EDITOR nvim
set -gx EDITOR_VISUAL nvim

# Fix emoji and others rendering
set -g fish_emoji_width 2
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore

# Link FlatHub Discord's IPC socket to the place where apps expect it
# ln -sf {app/com.discordapp.Discord,$XDG_RUNTIME_DIR}/discord-ipc-0

# Don't define these as that currently breaks the VSCode fish integration.
#
# function fish_right_prompt
# end
#
# function fish_mode_prompt
# end
