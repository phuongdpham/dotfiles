# Config start fnm with fish
if type -q fnm
    # --use-on-cd can sometimes trigger subshell path stacking
    # FNM handles its own pathing, but ensuring it's only sourced once is key
    status is-interactive; and fnm env --use-on-cd --shell fish | source
end
