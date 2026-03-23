#!/bin/bash
# notify-done.sh — macOS notification when Claude Code stops
# Shows session name (if set) or summary, plus project name.
#
# Input: Stop hook JSON on stdin
# Output: macOS notification via osascript

set -e

# Read JSON from stdin
INPUT=$(cat)

# Extract fields from hook input
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

# Get project name from cwd (last directory component)
PROJECT=$(basename "${CWD:-unknown}")

# Get session name from transcript (custom-title entry from /rename command)
SESSION_NAME=$(python3 -c "
import json, os

transcript_path = '$TRANSCRIPT_PATH'

if transcript_path and os.path.exists(transcript_path):
    with open(transcript_path) as f:
        for line in f:
            try:
                data = json.loads(line.strip())
                if data.get('type') == 'custom-title':
                    print(data.get('customTitle', ''))
                    break
            except json.JSONDecodeError:
                pass
" 2>/dev/null)

# Send macOS notification
if [ -n "$SESSION_NAME" ]; then
    osascript -e "display notification \"\" with title \"$PROJECT\" subtitle \"$SESSION_NAME\""
else
    osascript -e "display notification \"\" with title \"$PROJECT\" subtitle \"Claude Code Done\""
fi
