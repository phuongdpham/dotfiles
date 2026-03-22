function cz_sync
    # 1. Capture the list of changes
    set -l changes (chezmoi status)

    if test -z "$changes"
        echo (set_color green)"✔ Everything is up to date."(set_color normal)
        return
    end

    # 2. The FZF Selector with Live Preview
    # TAB to select multiple files, ENTER to confirm sync
    set -l selected (printf "%s\n" $changes | fzf -m \
        --ansi \
        --header "TAB: Select multiple | ENTER: Atomic Sync | ESC: Cancel" \
        --preview "chezmoi diff (string replace -r '^.{3}' '' <<< {})" \
        --preview-window "right:65%:wrap" \
        | string replace -r '^.{3}' '')

    # Exit if nothing was selected (ESC or empty ENTER)
    if test -z "$selected"
        echo (set_color red)"✘ Sync cancelled."(set_color normal)
        return
    end

    # 3. Perform the Atomic Push
    echo (set_color cyan)"Bundling "(count $selected)" files into a single commit/push..."(set_color normal)

    # Prepend HOME to ensure chezmoi add finds the files correctly
    set -l full_paths
    for f in $selected
        set -a full_paths "$HOME/$f"
    end

    if chezmoi add $full_paths
        echo (set_color green)"✔ Successfully synced to remote."(set_color normal)

        # 4. The "Senior Dev" Optimization: Auto-reload Niri
        # If any selected file matches the Niri config path, reload the compositor
        if string match -q "*.config/niri/config.kdl" $selected
            niri msg action do-reload
            echo (set_color blue)"⚡ Niri configuration reloaded."(set_color normal)
        end
    else
        echo (set_color red)"✘ Sync failed. Check your SSH/Network connection."(set_color normal)
    end
end
