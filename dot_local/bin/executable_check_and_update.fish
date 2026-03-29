#!/usr/bin/fish

# 1. Silent Check
set -l pac_updates (checkupdates 2>/dev/null | count)
set -l aur_updates (yay -Qu 2>/dev/null | count)
set -l total (math $pac_updates + $aur_updates)

if test $total -eq 0
    exit 0
end

# 2. Trigger Interactive Alacritty
if not contains -- --run-update $argv
    alacritty --title SystemUpdate -e fish -c "~/.local/bin/check_and_update.fish --run-update"
    exit 0
end

# 3. Actual Update Logic
echo (set_color cyan)"📦 $total updates found"(set_color normal)
set -l log_file /tmp/sys_update.log

if sudo pacman -Syu --noconfirm >$log_file 2>&1; and yay -Syu --noconfirm >>$log_file 2>&1
    echo (set_color green)"✔ System updated successfully."(set_color normal)

    # --- START OF POST-UPDATE HOOK ---
    echo (set_color yellow)"🧹 Cleaning Pacman cache..."(set_color normal)

    # Capture disk usage before
    set -l before (df -h / | awk 'NR==2 {print $4}')

    # 1. Keep only the last 3 versions of installed packages
    sudo paccache -r >>$log_file 2>&1

    # 2. Remove all versions of uninstalled packages (true housecleaning)
    sudo paccache -ruk0 >>$log_file 2>&1

    # Capture disk usage after
    set -l after (df -h / | awk 'NR==2 {print $4}')

    echo (set_color green)"✔ Cache pruned. Free space: $before -> $after"(set_color normal)
    # --- END OF POST-UPDATE HOOK ---

    notify-send -u low "Arch Updated" "Disk space optimized: $after available."
    sleep 3
else
    notify-send -u critical "Update Failed" "Check $log_file"
    echo (set_color red)"✘ Errors occurred. Press any key to inspect."(set_color normal)
    read -n 1
end
