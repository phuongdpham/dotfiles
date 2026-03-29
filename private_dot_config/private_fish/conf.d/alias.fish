# abbr --add ls ls --human-readable --literal --group-directories-first --color=auto
# abbr --add l ls -l
# abbr --add la l -a

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

# Docker and Docker compose
abbr --add dcud docker compose up -d
abbr --add dcd docker compose down
abbr --add dps docker ps

# 'czp' for 'chezmoi push'
abbr -a czp cz_sync
