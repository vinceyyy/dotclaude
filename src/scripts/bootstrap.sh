#!/bin/bash

# Claude Code Configuration Kit — Bootstrap Script
# Creates symlinks from ~/.claude/ into this repo
# Safe to re-run (idempotent)

set -e

echo "=== Claude Code Configuration Kit Bootstrap ==="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Repo directory: $REPO_DIR"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    echo "  Claude Code not found. Install: curl -fsSL https://claude.ai/install.sh | bash"
    exit 1
fi
echo "  Claude Code installed"

if ! command -v git &> /dev/null; then
    echo "  git not found. Install Xcode command line tools: xcode-select --install"
    exit 1
fi
echo "  git installed"
echo ""

# Create ~/.claude if needed
mkdir -p ~/.claude

# --- User CLAUDE.md symlink ---
if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
    echo "Backing up existing ~/.claude/CLAUDE.md to ~/.claude/CLAUDE.md.backup..."
    mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
fi

if [ -L ~/.claude/CLAUDE.md ]; then
    rm ~/.claude/CLAUDE.md
fi

ln -s "$REPO_DIR/src/user/CLAUDE.md" ~/.claude/CLAUDE.md
echo "User memory symlink created: ~/.claude/CLAUDE.md -> $REPO_DIR/src/user/CLAUDE.md"

# --- Rules symlink ---
if [ -d ~/.claude/rules ] && [ ! -L ~/.claude/rules ]; then
    echo "Backing up existing ~/.claude/rules to ~/.claude/rules.backup..."
    mv ~/.claude/rules ~/.claude/rules.backup
fi

if [ -L ~/.claude/rules ]; then
    rm ~/.claude/rules
fi

ln -s "$REPO_DIR/src/rules" ~/.claude/rules
echo "Rules symlink created: ~/.claude/rules -> $REPO_DIR/src/rules"

# --- Skills symlink ---
if [ -d ~/.claude/skills ] && [ ! -L ~/.claude/skills ]; then
    echo "Backing up existing ~/.claude/skills to ~/.claude/skills.backup..."
    mv ~/.claude/skills ~/.claude/skills.backup
fi

if [ -L ~/.claude/skills ]; then
    rm ~/.claude/skills
fi

ln -s "$REPO_DIR/src/skills" ~/.claude/skills
echo "Skills symlink created: ~/.claude/skills -> $REPO_DIR/src/skills"

# --- Remove stale commands symlink if present ---
if [ -L ~/.claude/commands ]; then
    rm ~/.claude/commands
    echo "Removed stale commands symlink"
fi
echo ""

# --- Validate notify-done hook path ---
NOTIFY_HOOK="$REPO_DIR/src/hooks/notify-done"
if [ -d "$NOTIFY_HOOK" ]; then
    echo "notify-done hook found at: $NOTIFY_HOOK"
else
    echo "Warning: notify-done hook not found at $NOTIFY_HOOK"
fi
echo ""

# --- Verify setup ---
echo "Verifying setup..."

if [ -L ~/.claude/CLAUDE.md ] && [ -f ~/.claude/CLAUDE.md ]; then
    echo "  User memory: OK"
else
    echo "  User memory: FAILED"
fi

if [ -L ~/.claude/rules ] && [ -d ~/.claude/rules ]; then
    RULE_COUNT=$(ls ~/.claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  Rules: $RULE_COUNT files"
else
    echo "  Rules: FAILED"
fi

if [ -L ~/.claude/skills ] && [ -d ~/.claude/skills ]; then
    SKILL_COUNT=$(ls ~/.claude/skills/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  Skills: $SKILL_COUNT files"
else
    echo "  Skills: FAILED"
fi

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "  1. Configure ~/.claude/settings.json (see docs/getting-started.md)"
echo "  2. Recommended settings.json snippet:"
echo ""
echo '  {'
echo '    "hooks": {'
echo '      "Notification": ['
echo '        {'
echo '          "hooks": ['
echo '            {'
echo '              "type": "command",'
echo "              \"command\": \"$REPO_DIR/src/hooks/notify-done/notify-done.sh\""
echo '            }'
echo '          ]'
echo '        }'
echo '      ]'
echo '    },'
echo '    "statusLine": {'
echo '      "type": "command",'
echo "      \"command\": \"$REPO_DIR/src/scripts/statusline-command.sh\""
echo '    }'
echo '  }'
echo ""
