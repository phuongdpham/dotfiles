#!/usr/bin/fish

# 2026 Pattern: Use 'command -v' for dependency checks
for cmd in checkupdates yay alacritty notify-send
    if not command -v $cmd >/dev/null
        echo (set_color red)"✘ Missing dependency: $cmd"(set_color normal)
        exit 1
    end
end

# Logic: Unified Update Check
set -l updates (checkupdates 2>/dev/null; yay -Qu 2>/dev/null)
set -l count (count $updates)

if test $count -gt 0
    # Use Alacritty's modern 'hold' flag if you want to inspect manually
    # or use the pipe logic we built earlier.
    alacritty --title SystemUpdate -e fish -c "
        echo (set_color cyan)'󰚰 System has $count pending updates'(set_color normal)
        sudo pacman -Syu --noconfirm --color always | tee /tmp/pacman.log
        yay -Syu --noconfirm --color always | tee -a /tmp/pacman.log
        
        # 2026 Housekeeping: Pruning the cache
        sudo paccache -rk2 # Keep only 2 versions for tighter disk control
        
        echo (set_color green)'✔ Update complete. (Closing in 5s)'(set_color normal)
        sleep 5
    "
else
    # Silent log for your audit trail
    echo "[$(date +%H:%M:%S)] System is clean." >>/tmp/update_check.log
end
