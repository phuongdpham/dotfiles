#!/usr/bin/env bash
# Claude Code status line — simple, Nerd Font glyphs, dark-terminal palette

# ANSI colors (dimmed-friendly)
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[38;5;81m'
GREEN='\033[38;5;114m'
YELLOW='\033[38;5;221m'
MAGENTA='\033[38;5;183m'
GRAY='\033[38;5;245m'
BLUE='\033[38;5;110m'
SOFT_GREEN='\033[38;5;150m'   # cost segment
AMBER='\033[38;5;214m'        # rate limit warning
PURPLE='\033[38;5;141m'       # think effort

SEP="${GRAY}│${RESET}"

input=$(cat)

if command -v jq >/dev/null 2>&1; then
    model=$(echo "$input"      | jq -r '.model.display_name // "Claude"')
    cwd=$(echo "$input"        | jq -r '.workspace.current_dir // .cwd // ""')
    proj=$(echo "$input"       | jq -r '.workspace.project_dir // ""')
    used=$(echo "$input"       | jq -r '.context_window.used_percentage // empty')
    git_wt=$(echo "$input"     | jq -r '.workspace.git_worktree // empty')
    vim_mode=$(echo "$input"   | jq -r '.vim.mode // empty')
    # Cost (real USD), duration, and token counts
    cost_usd=$(echo "$input"   | jq -r '.cost.total_cost_usd // empty')
    duration_ms=$(echo "$input"| jq -r '.cost.total_duration_ms // empty')
    tok_in=$(echo "$input"     | jq -r '.context_window.total_input_tokens // empty')
    ctx_size=$(echo "$input"   | jq -r '.context_window.context_window_size // empty')
    # Rate limits
    rl5_pct=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
    rl7_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
    # Thinking / effort / fast mode
    thinking=$(echo "$input"   | jq -r '.thinking.enabled // empty')
    effort=$(echo "$input"     | jq -r '.effort.level // empty')
    fast_mode=$(echo "$input"  | jq -r '.fast_mode // empty')
else
    # Graceful fallback: no jq
    model="Claude"
    cwd="$PWD"
    proj=""
    used=""
    git_wt=""
    vim_mode=""
    cost_usd=""
    duration_ms=""
    tok_in=""
    ctx_size=""
    rl5_pct=""
    rl7_pct=""
    thinking=""
    effort=""
    fast_mode=""
fi

# ── Directory ────────────────────────────────────────────────────────────────
# Show basename of cwd; if cwd == project_dir show project basename instead
if [ -n "$proj" ] && [ "$cwd" = "$proj" ]; then
    dir_label=$(basename "$proj")
elif [ -n "$cwd" ]; then
    dir_label=$(basename "$cwd")
else
    dir_label=$(basename "$PWD")
fi

# ── Git branch ───────────────────────────────────────────────────────────────
git_branch=""
git_dir="${cwd:-$PWD}"
if [ -n "$git_wt" ]; then
    git_branch="$git_wt"
elif branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$git_dir" symbolic-ref --short HEAD 2>/dev/null); then
    git_branch="$branch"
fi

# ── Render ────────────────────────────────────────────────────────────────────
# Nerd Font glyphs via bash $'\U...' literals
G_MODEL=$'\Uf1719'   # nf-md-robot_happy
G_DIR=$'\Uf0770'     # nf-md-folder_open
G_BRANCH=$'\Ue0a0'   # nf-dev-git_branch
G_CTX=$'\Uf0e7'      # nf-md-lightning_bolt
G_VIM=$'\Ueb62'      # nf-cod-symbol_keyword
G_COST=$'\Uefca'     # nf-fa-money_check_dollar
G_RATE=$'\Uf463'     # nf-oct-meter
G_THINK=$'\Uee9c'    # nf-fa-brain (Font Awesome 6, in CaskaydiaCove)
G_TIME=$'\Uf1442'    # nf-md-clock_time_four (session duration)
G_FAST=$'\Uf0e7'     # nf-fa-bolt (fast mode marker)

# Model segment — append a small ⚡ when fast mode is on
fast_suffix=""
if [ "$fast_mode" = "true" ]; then
    fast_suffix=" ${YELLOW}${G_FAST}${RESET}"
fi
printf "${BOLD}${MAGENTA}${G_MODEL} ${model}${RESET}${fast_suffix}"
printf " ${SEP} ${CYAN}${G_DIR} ${dir_label}${RESET}"

if [ -n "$git_branch" ]; then
    printf " ${SEP} ${GREEN}${G_BRANCH} ${git_branch}${RESET}"
fi

# Format a token count: 92961 -> "92.9k", 1000000 -> "1M", 500 -> "500"
fmt_tok() {
    local n="$1"
    if [ -z "$n" ] || [ "$n" -le 0 ] 2>/dev/null; then printf ''; return; fi
    if   [ "$n" -ge 1000000 ]; then awk "BEGIN{printf \"%.1fM\", $n/1000000}" | sed 's/\.0M/M/'
    elif [ "$n" -ge 1000 ];    then awk "BEGIN{printf \"%.1fk\", $n/1000}"   | sed 's/\.0k/k/'
    else printf '%s' "$n"
    fi
}

if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    if   [ "$used_int" -ge 80 ]; then ctx_color='\033[38;5;203m'
    elif [ "$used_int" -ge 50 ]; then ctx_color="$YELLOW"
    else                               ctx_color="$BLUE"
    fi
    # Append "tok_in/ctx_size" when both are known
    ctx_extra=""
    if [ -n "$tok_in" ] && [ -n "$ctx_size" ]; then
        ctx_extra=" ${GRAY}$(fmt_tok "$tok_in")/$(fmt_tok "$ctx_size")${RESET}"
    fi
    printf " ${SEP} ${ctx_color}${G_CTX} ${used_int}%%${RESET}${ctx_extra}"
fi

if [ -n "$vim_mode" ]; then
    printf " ${SEP} ${YELLOW}${G_VIM} ${vim_mode}${RESET}"
fi

# ── Cost (USD) ───────────────────────────────────────────────────────────────
# Real session cost from cost.total_cost_usd. Format: $0.05, $2.00, $15.32.
# Sub-cent values render as <$0.01 to avoid showing $0.00 after a request lands.
if [ -n "$cost_usd" ]; then
    cost_fmt=$(awk "BEGIN{
        c=$cost_usd
        if (c<=0)        { print \"\" }
        else if (c<0.01) { printf \"<\$0.01\" }
        else             { printf \"\$%.2f\", c }
    }")
    if [ -n "$cost_fmt" ]; then
        printf " ${SEP} ${SOFT_GREEN}${G_COST} ${cost_fmt}${RESET}"
    fi
fi

# ── Session duration ─────────────────────────────────────────────────────────
# cost.total_duration_ms — wall-clock time since session started.
# Format: <60s -> "Xs", <60m -> "Xm", >=60m -> "XhYm"
if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    secs=$((duration_ms / 1000))
    if   [ "$secs" -lt 60 ];   then dur_fmt="${secs}s"
    elif [ "$secs" -lt 3600 ]; then dur_fmt="$((secs/60))m"
    else                            dur_fmt="$((secs/3600))h$(((secs%3600)/60))m"
    fi
    printf " ${SEP} ${GRAY}${G_TIME} ${dur_fmt}${RESET}"
fi

# ── Rate limits ──────────────────────────────────────────────────────────────
# Show 5-hour and/or 7-day used% when present; amber when >=70%, gray otherwise.
rl_parts=""
if [ -n "$rl5_pct" ]; then
    rl5_int=$(printf '%.0f' "$rl5_pct")
    if [ "$rl5_int" -ge 70 ]; then rl5_color="$AMBER"; else rl5_color="$GRAY"; fi
    rl_parts="${rl5_color}5h:${rl5_int}%%${RESET}"
fi
if [ -n "$rl7_pct" ]; then
    rl7_int=$(printf '%.0f' "$rl7_pct")
    if [ "$rl7_int" -ge 70 ]; then rl7_color="$AMBER"; else rl7_color="$GRAY"; fi
    if [ -n "$rl_parts" ]; then
        rl_parts="${rl_parts} ${rl7_color}7d:${rl7_int}%%${RESET}"
    else
        rl_parts="${rl7_color}7d:${rl7_int}%%${RESET}"
    fi
fi
if [ -n "$rl_parts" ]; then
    printf " ${SEP} ${GRAY}${G_RATE}${RESET} ${rl_parts}"
fi

# ── Thinking / effort ────────────────────────────────────────────────────────
# Show when thinking is enabled or an effort level is set.
# effort.level values: low medium high xhigh max
think_label=""
if [ -n "$effort" ]; then
    think_label="$effort"
elif [ "$thinking" = "true" ]; then
    think_label="on"
fi
if [ -n "$think_label" ]; then
    printf " ${SEP} ${PURPLE}${G_THINK} ${think_label}${RESET}"
fi

printf '\n'
