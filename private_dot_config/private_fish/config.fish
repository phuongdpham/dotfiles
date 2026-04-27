if status is-interactive
    # Commands to run in interactive sessions can go here
    # We no longer need 'set -gx EDITOR' here because 
    # Fish inherited it from the UWSM session.

    # Interactive shortcuts (Abbreviations)
    abbr -a cz chezmoi
    abbr -a n nvim

    # Safety check: fish_add_path is idempotent, so it won't 
    # duplicate even if UWSM already set it.
    fish_add_path ~/.local/bin

    # --- Quick Audio & Device Controls ---
    # Launch your new floating Arturia/Volume mixer
    abbr -a vmix 'flatpak run com.saivert.pwvucontrol'

    # Quick Bluetooth management
    abbr -a btm blueman-manager
    abbr -a bton 'bluetoothctl power on'

    # --- Development & Projects ---
    # Quickly jump into your main Go project

    # --- System & Niri ---
    # Reload niri config after you make changes
    abbr -a nrel 'niri msg action reload-config'

    # Identify windows for your config.kdl rules
    abbr -a nwin 'niri msg windows'
end

function fish_greeting
end

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
