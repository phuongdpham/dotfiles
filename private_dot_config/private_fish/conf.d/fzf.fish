# Load fzf integration (this must happen AFTER the function above)
if type -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --info=inline --prompt='λ ' --pointer='▶' --marker='✓'"
end

# Customize fzf colors and layout
set -gx FZF_DEFAULT_OPTS "
  --height 40% 
  --layout reverse 
  --border 
  --color=bg+:#2e3c64,bg:#1a1b26,spinner:#bb9af7,hl:#7dcfff 
  --color=fg:#a9b1d6,header:#9ece6a,info:#0db9d7,pointer:#bb9af7 
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7dcfff
"
