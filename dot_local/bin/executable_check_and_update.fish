#!/usr/bin/fish

# 1. Dependency Check
for cmd in checkupdates yay alacritty notify-send
    if not command -v $cmd >/dev/null
        echo (set_color red)"✘ Missing dependency: $cmd"(set_color normal)
        exit 1
    end
end

# 2. Setup Persistent Log Path (Using Chezmoi Template)
set -l log_file "{{ .chezmoi.homeDir }}/.local/state/pacman_updates.log"
mkdir -p (dirname $log_file)

# 3. Check for updates
set -l updates (checkupdates 2>/dev/null; yay -Qu 2>/dev/null)
set -l count (count $updates)

if test $count -gt 0
    # 4. Interactive Notification
    set -l action (notify-send "󰚰 System Updates" \
        "There are $count updates available." \
        --icon=system-software-update \
        --action="update=Update Now" \
        --wait)

    if test "$action" = update
        alacritty --title "System Update" -e fish -c "
            echo (set_color cyan)'󰚰 Starting update at '(date +'%Y-%m-%d %H:%M:%S')'...'(set_color normal)
            
            # Header for the log file
            echo \"--- Update Session: \$(date) ---\" >> $log_file

            # Update Core System
            sudo pacman -Syu --noconfirm --color always | tee -a $log_file
            set -l pac_status \$pipestatus[1]

            # Update AUR
            yay -Syu --noconfirm --color always | tee -a $log_file
            set -l yay_status \$pipestatus[1]

            # 5. Logical Error Check (The 'Senior' Check)
            if test \$pac_status -eq 0 -a \$yay_status -eq 0
                sudo paccache -rk2
                echo (set_color green)'✔ System updated successfully.'(set_color normal)
                echo \"Status: SUCCESS\" >> $log_file
            else
                echo (set_color red)'✘ Update failed. Check $log_file'(set_color normal)
                echo \"Status: FAILED (Pacman: \$pac_status, Yay: \$yay_status)\" >> $log_file
            end

            echo 'Closing in 10 seconds...'
            sleep 10
        "
    end
else
    # Minimalist logging for clean systems
    echo "[$(date +%H:%M:%S)] System is clean." >>"$log_file"
end
