# abbr --add ls ls --human-readable --literal --group-directories-first --color=auto
# abbr --add l ls -l
# abbr --add la l -a

if status is-interactive
    # --- Quick Audio & Device Controls ---
    # Launch your new floating Arturia/Volume mixer
    abbr -a vmix 'flatpak run com.saivert.pwvucontrol'

    # Quick Bluetooth management
    abbr -a btm blueman-manager
    abbr -a bton 'bluetoothctl power on'

    # --- Development & Projects ---
    # Quickly jump into your main Go project
    # abbr -a andpad 'cd ~/path/to/andpad-apis'

    # Launch IDEs (assuming they are in your PATH)
    abbr -a go 'goland .'
    abbr -a py 'pycharm .'

    # --- System & Niri ---
    # Reload niri config after you make changes
    abbr -a nrel 'niri msg action do-reload'

    # Identify windows for your config.kdl rules
    abbr -a nwin 'niri msg windows'
end

if type -q eza
    alias ls 'eza --grid --long --icons --header --group-directories-first --color=always --git --binary --modified'
    abbr --add l ls -l
    abbr --add la ls -la
    abbr --add lt eza --tree --level=2 --icons
end

abbr --add mkdir mkdir -p
abbr --add mv mv -i

abbr --add p pacman
abbr --add pu sudo pacman -Syu
abbr --add pq pacman -Q
abbr --add pqi pacman -Qi
abbr --add pql pacman -Ql
abbr --add pr sudo pacman -Rscn
abbr --add pss pacman -Ss
abbr --add psy sudo pacman -Sy
abbr --add psyu sudo pacman -Syu
abbr --add spm sudo pacman

abbr --add pa pacaur -S
abbr --add pas pacaur -Ss

# flatpak autocomplete is broken with an alias
abbr --add f flatpak
abbr --add fu flatpak update
abbr --add fi flatpak install
abbr --add fiu flatpak install --user

abbr --add c cargo
abbr --add cn cargo +nightly

abbr --add sc systemctl
abbr --add scu systemctl --user

abbr --add jc journalctl
abbr --add jcn journalctl --no-hostname
abbr --add jcnb journalctl --no-hostname -b
abbr --add jcneb journalctl --no-hostname -eb
abbr --add jcnuu journalctl --no-hostname --user-unit
