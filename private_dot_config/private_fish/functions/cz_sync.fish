function cz_sync
    # 1. Capture the list of changes
    set -l changes (chezmoi status)

    if test -z "$changes"
        echo (set_color green)"✔ Everything is up to date."(set_color normal)
        return
    end

    # 2. Interactive Selection (with IPS-optimized preview and scrolling)
    set -l selected (printf "%s\n" $changes | fzf -m \
        --ansi \
        --header "TAB: Select | ENTER: Sync | ESC: Cancel | ALT-J/K: Scroll" \
        --bind "alt-j:preview-down" \
        --bind "alt-k:preview-up" \
        --preview "chezmoi diff {2..} | delta --width (math \$FZF_PREVIEW_COLUMNS - 2) --features ips-slate" \
        --preview-window "right:65%:wrap" \
        | string replace -r '^.{3}' '')

    if test -z "$selected"
        return
    end

    # 3. Handle Optional Commit Message
    set -l add_args
    if test (count $argv) -gt 0
        set add_args --message "$argv"
    end

    # 4. Atomic Push (Triggers git.autoCommit & git.autoPush)
    echo (set_color cyan)"Pushing "(count $selected)" files to GitHub..."(set_color normal)

    set -l full_paths
    for f in $selected
        set -a full_paths "$HOME/$f"
    end

    if chezmoi add $add_args $full_paths
        echo (set_color green)"✔ Successfully pushed to remote repository."(set_color normal)
    else
        echo (set_color red)"✘ Sync failed. Check network/SSH."(set_color normal)
    end
end
