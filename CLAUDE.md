# Claude Code Configuration Kit

This repo manages Claude Code configuration (rules, skills, hooks) via symlinks from `~/.claude/` into this repo. Fork
it, customize it, make it yours.

## First-Time Setup

On every conversation start in this repo, check if `~/.claude/rules`, `~/.claude/skills`, and `~/.claude/CLAUDE.md` are
symlinks pointing into this repo. If not, immediately start the setup process below — don't wait for the user to ask.

### 1. Check if already configured

```bash
# Check for existing symlinks
ls -la ~/.claude/rules 2>/dev/null
ls -la ~/.claude/skills 2>/dev/null
```

If both symlinks exist and point into this repo, skip to "Verify Setup". Otherwise, continue.

### 2. Run bootstrap

```bash
./src/scripts/bootstrap.sh
```

This creates symlinks from `~/.claude/` into this repo. It is idempotent (safe to re-run).

### 3. Configure settings.json

Check if `~/.claude/settings.json` exists. If it doesn't, or if it's missing the hooks/statusLine config, help the user
create or update it with:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<REPO_DIR>/src/hooks/notify-done/notify-done.sh"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "<REPO_DIR>/src/scripts/statusline-command.sh"
  },
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true,
    "episodic-memory@superpowers-marketplace": true,
    "elements-of-style@superpowers-marketplace": true,
    "code-simplifier@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "explanatory-output-style@claude-plugins-official": true,
    "ralph-loop@claude-plugins-official": true
  }
}
```

Replace `<REPO_DIR>` with the absolute path to this repo. Merge with any existing settings — don't overwrite.

Explain what each setting does:

- **Notification hook**: Plays a sound and shows a macOS notification when you finish a task
- **Status line**: Shows git branch, model, context usage, and rate limit info
- **Plugins**: superpowers (workflow skills), episodic-memory (cross-session memory), elements-of-style (writing
  quality), code-simplifier (code cleanup), code-review (PR reviews), feature-dev (guided feature development),
  explanatory-output-style (educational insights), ralph-loop (autonomous iteration)

### 4. Verify setup

```bash
ls -la ~/.claude/CLAUDE.md  # Should be a symlink to src/user/CLAUDE.md
ls ~/.claude/rules/         # Should list rule .md files
ls ~/.claude/skills/        # Should show skill directories (if any added)
```

Tell the user they're ready. They can now `cd` to any project and run `claude` — the rules and skills will be available
automatically.

Point them to `docs/context-guide.md` if they want to understand how rules and skills work.

## How It Works

- `src/rules/` → symlinked to `~/.claude/rules/` (always loaded, every conversation)
- `src/skills/` → symlinked to `~/.claude/skills/` (loaded on demand by CC)
- `src/user/CLAUDE.md` → symlinked to `~/.claude/CLAUDE.md` (always loaded, CC writes to it)
- `src/hooks/` → referenced from `~/.claude/settings.json`
- Changes are hot-reloaded — edit a file, CC picks it up immediately

## File Structure

```
dotclaude/
├── src/
│   ├── rules/           # Mandatory constraints (always in context)
│   ├── skills/          # Reference documentation (on demand)
│   ├── user/            # User memory (learned patterns, symlinked to ~/.claude/CLAUDE.md)
│   ├── hooks/           # CC lifecycle hooks
│   │   └── notify-done/ # Desktop notification when CC finishes
│   └── scripts/         # Bootstrap and status line
├── scripts/
│   └── handoff-instruction.md  # Claude.ai instruction for project handoff
├── docs/
│   ├── getting-started.md  # Onboarding guide (human-readable)
│   ├── context-guide.md    # How CC context management works
│   └── design.md           # System architecture and decisions
└── CLAUDE.md              # You are here
```

## Working on This Repo

- Use feature branches (`feat/`, `fix/`, `refactor/`)
- Test changes by verifying CC behavior in another project
- Each skill is a directory with `SKILL.md` (frontmatter required for discovery)
