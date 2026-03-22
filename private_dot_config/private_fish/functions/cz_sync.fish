function cz_sync
    # 1. Capture changes
    set -l changes (chezmoi status)

    if test -z "$changes"
        echo (set_color green)"✔ Everything is up to date."(set_color normal)
        return
    end

    # Use {2..} to grab everything from the second field to the end (handles spaces in filenames)
    # Use delta for the preview. 
    # --width ensures it fits the fzf pane.
    # --features=magika (or your preferred theme) for OLED pop.
    set -l selected (printf "%s\n" $changes | fzf -m \
        --ansi \
        --header "TAB: Select | ENTER: Sync | ESC: Cancel" \
        --bind "ctrl-d:preview-page-down" \
        --bind "ctrl-u:preview-page-up" \
        --bind "alt-j:preview-down" \
        --bind "alt-k:preview-up" \
        --preview "chezmoi diff {2..} | delta --width (math \$FZF_PREVIEW_COLUMNS - 2) --features ips-slate" \
        --preview-window "right:65%:wrap" \
        | string replace -r '^.{3}' '')

    if test -z "$selected"
        return
    end

    # 3. Handle Commit Message
    # If you pass an argument: cz_sync "feat: update niri rules"
    set -l add_args
    if test (count $argv) -gt 0
        set add_args --message "$argv"
    end

    # 4. Atomic Sync
    echo (set_color cyan)"Syncing "(count $selected)" files..."(set_color normal)

    # Convert to full paths for chezmoi add
    set -l full_paths
    for f in $selected
        set -a full_paths "$HOME/$f"
    end

    if chezmoi add $add_args $full_paths
        echo (set_color green)"✔ Successfully pushed to GitHub."(set_color normal)

        # Auto-reload Niri if config was touched
        if string match -q "*.config/niri/config.kdl" $selected
            niri msg action do-reload
            echo (set_color blue)"⚡ Niri reloaded."(set_color normal)
        end
    end
end
