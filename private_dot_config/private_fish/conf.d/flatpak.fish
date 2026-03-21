# 1. Define the paths we want
set -l fp_system /var/lib/flatpak/exports/share
set -l fp_user "$HOME/.local/share/flatpak/exports/share"
set -l sys_paths /usr/local/share /usr/share

# 2. Start with a fresh local list to avoid nesting/duplicates
set -l new_xdg_paths

# 3. Add paths in order of priority (User Flatpak > System Flatpak > System)
for p in $fp_user $fp_system $sys_paths
    if test -d "$p"; and not contains "$p" $new_xdg_paths
        set -a new_xdg_paths "$p"
    end
end

# 4. The "Pro" Fix: Use --path to force colon-separation on export
set -gx --path XDG_DATA_DIRS $new_xdg_paths
