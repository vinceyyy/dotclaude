#!/bin/bash

# Claude Code Statusline Command
# Shows: project | branch(*+) | model | ctx: ██████░░░░ 60% | usage: 45% (5h) · 12% (weekly)
#
# Configure in ~/.claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "<REPO_DIR>/src/scripts/statusline-command.sh"
#   }

# Read JSON input
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.cwd')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')

# Use cwd (where Claude is actually running) for git operations, not project_dir
# This correctly handles worktrees since each worktree has its own working directory
git_branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
# Before first commit, rev-parse returns "HEAD" — fall back to reading .git/HEAD
if [ "$git_branch" = "HEAD" ]; then
    git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
    if [ -n "$git_dir" ] && [ -f "$git_dir/HEAD" ]; then
        git_branch=$(sed 's|ref: refs/heads/||' "$git_dir/HEAD")
    fi
fi
model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# Build output
output="$(basename "$cwd")"
if [ -n "$git_branch" ]; then
    git -C "$cwd" diff --quiet 2>/dev/null && modified=0 || modified=1
    git -C "$cwd" diff --cached --quiet 2>/dev/null && staged=0 || staged=1
    flags=""
    [ "$modified" -eq 1 ] && flags="${flags}*"
    [ "$staged" -eq 1 ] && flags="${flags}+"
    output="$output ($git_branch$flags)"
fi
output="$output | $model"

# Add progress bar if context usage is available
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct")
    filled=$((used_int / 10))
    empty=$((10 - filled))

    bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    output="$output | ctx: $bar ${used_int}%"
fi

# --- Usage limits (OAuth API with file cache) ---
CACHE_FILE="$HOME/.claude/.usage-cache.json"
CACHE_TTL=60  # seconds

fetch_usage() {
    local token
    token=$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
    [ -z "$token" ] && return 1

    local resp
    resp=$(curl -s --max-time 5 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    [ -z "$resp" ] && return 1

    # Validate response has expected fields
    echo "$resp" | jq -e '.five_hour.utilization' >/dev/null 2>&1 || return 1

    # Write cache
    jq -n --argjson ts "$(date +%s)" --argjson data "$resp" \
        '{"timestamp": $ts, "data": $data}' > "$CACHE_FILE" 2>/dev/null
    echo "$resp"
}

get_usage() {
    # Try cache first
    if [ -f "$CACHE_FILE" ]; then
        local cached_ts now age
        cached_ts=$(jq -r '.timestamp // 0' "$CACHE_FILE" 2>/dev/null)
        now=$(date +%s)
        age=$((now - cached_ts))
        if [ "$age" -lt "$CACHE_TTL" ]; then
            jq -r '.data' "$CACHE_FILE" 2>/dev/null
            return
        fi
    fi

    # Cache miss or stale — fetch in background, use stale cache for now
    if [ -f "$CACHE_FILE" ]; then
        # Return stale data immediately, refresh in background
        jq -r '.data' "$CACHE_FILE" 2>/dev/null
        ( fetch_usage >/dev/null 2>&1 & )
    else
        # No cache at all — must fetch synchronously (first run only)
        fetch_usage
    fi
}

usage_json=$(get_usage)
if [ -n "$usage_json" ]; then
    five_h=$(echo "$usage_json" | jq -r '.five_hour.utilization // empty')
    seven_d=$(echo "$usage_json" | jq -r '.seven_day.utilization // empty')
    five_h_reset=$(echo "$usage_json" | jq -r '.five_hour.resets_at // empty')
    seven_d_reset=$(echo "$usage_json" | jq -r '.seven_day.resets_at // empty')

    if [ -n "$five_h" ] && [ -n "$seven_d" ]; then
        five_int=$(printf "%.0f" "$five_h")
        seven_int=$(printf "%.0f" "$seven_d")

        # Build usage string: "5h% · weekly%"
        usage_str="usage: ${five_int}% (5h) · ${seven_int}% (weekly)"

        # Append reset time if either usage is above 80%
        if [ "$five_int" -gt 80 ] || [ "$seven_int" -gt 80 ]; then
            if [ "$five_int" -gt 80 ]; then
                reset_time="$five_h_reset"
            else
                reset_time="$seven_d_reset"
            fi

            if [ -n "$reset_time" ]; then
                # Convert to local time string (e.g. "Sat 3:00 PM")
                local_reset=$(python3 -c "
from datetime import datetime, timezone
import time
dt = datetime.fromisoformat('$reset_time').astimezone()
print(dt.strftime('%a %-I:%M %p'))" 2>/dev/null)

                [ -n "$local_reset" ] && usage_str="$usage_str resets $local_reset"
            fi
        fi

        output="$output | $usage_str"
    fi
fi

# Add vim mode if present
[ -n "$vim_mode" ] && output="$output | $vim_mode"

echo "$output"
