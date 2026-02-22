alias ls "ls --human-readable --literal --group-directories-first --color=auto"
# alias ls "eza --group-directories-first"
alias l "ls -l"
alias la "l -a"

alias mkdir "mkdir -p"
alias mv "mv -i"

alias p    "pacman"
alias pu   "sudo pacman -Syu"
alias pq   "pacman -Q"
alias pqi  "pacman -Qi"
alias pql  "pacman -Ql"
alias pr   "sudo pacman -Rscn"
alias pss  "pacman -Ss"
alias psy  "sudo pacman -Sy"
alias psyu "sudo pacman -Syu"
alias spm  "sudo pacman"

alias pa   "pacaur -S"
alias pas  "pacaur -Ss"

# flatpak autocomplete is broken with an alias
abbr --add f   flatpak
abbr --add fu  flatpak update
abbr --add fi  flatpak install
abbr --add fiu flatpak install --user

alias c "cargo"
alias cn "cargo +nightly"

alias sc  "systemctl"
alias scu "systemctl --user"

alias jc    "journalctl"
alias jcn   "journalctl --no-hostname"
alias jcnb  "journalctl --no-hostname -b"
alias jcneb "journalctl --no-hostname -eb"
alias jcnuu "journalctl --no-hostname --user-unit"
