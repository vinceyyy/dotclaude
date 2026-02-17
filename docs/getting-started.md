# Getting Started

Getting started with the Claude Code Configuration Kit -- a fork-and-own configuration system distributed via git.

## What is Claude Code?

Claude Code is Anthropic's CLI tool for AI-assisted software development. You run it in your terminal inside any
project, and it can read your code, write files, run commands, and help you build software. Think of it as an AI pair
programmer that lives in your terminal.

This repo provides **your configuration** -- coding standards, workflow patterns, and learned knowledge -- so every
Claude Code session follows your conventions automatically.

## Quick Start

### 1. Install Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

No Node.js required. Auto-updates are included. You need a Claude Pro, Max, Teams, or Enterprise plan.

### 2. Clone and set up

```bash
git clone <repo-url>
cd dotclaude
claude --dangerously-skip-permissions
```

The `--dangerously-skip-permissions` flag lets Claude Code run the setup without prompting for approval on each step.
This is safe here -- the bootstrap script only creates symlinks and the repo is trusted.

Claude Code reads this repo's `CLAUDE.md` and walks you through setup: running the bootstrap script, configuring
`settings.json`, and verifying everything works. Just follow its prompts.

### Manual setup (without Claude Code)

If you prefer to set up manually:

1. Run the bootstrap script:

   ```bash
   ./src/scripts/bootstrap.sh
   ```

   This creates symlinks so Claude Code picks up your configuration:

   - `~/.claude/CLAUDE.md` -> `src/user/CLAUDE.md` (user memory)
   - `~/.claude/rules/` -> `src/rules/` (7 rule files)
   - `~/.claude/skills/` -> `src/skills/` (skill directories, if any added)

2. Configure `~/.claude/settings.json` (see next section).

## Recommended settings.json

The bootstrap script prints a recommended `settings.json` snippet. Create or update `~/.claude/settings.json`:

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
  }
}
```

Replace `<REPO_DIR>` with the absolute path to your clone of this repo.

**Notification hook**: Plays a sound and shows a macOS notification when Claude finishes a task, so you can step away
and come back when it's done.

**Status line**: Shows project name, git branch (with `*` for unstaged and `+` for staged changes), model name, context
window usage bar, and OAuth usage limits (5-hour and weekly). When usage exceeds 80%, it shows the reset time.

### Recommended plugins

Add these to `~/.claude/settings.json`. The `extraKnownMarketplaces` entry auto-registers the superpowers marketplace
(no manual `/plugin marketplace add` needed):

```json
{
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

## Using Claude Code

After setup, Claude Code is ready to use in any project:

```bash
cd ~/Code/your-project
claude
```

That's it. Your rules and skills are automatically available in every session. You don't need to reference them
explicitly -- Claude Code loads rules on its own and consults skills when relevant.

**Things to try in your first session:**

- "What rules do you have?" -- confirms your config is loaded
- "Help me build a FastAPI endpoint for user registration" -- Claude will follow your conventions automatically
- Ask about architecture, code review, or debugging -- skills provide context on your patterns

## Verifying Your Setup

After bootstrap, confirm everything is wired up:

```bash
# Should list 7 .md files
ls ~/.claude/rules/

# Should show skill directories (empty in public template)
ls ~/.claude/skills/

# Quick smoke test -- open CC in any project and ask:
# "What rules do you have?"
# It should reference coding-style, git, python, security, typescript, documentation, and learning.
```

## Updating

```bash
cd <path-to-dotclaude>
git pull
```

Changes to rules and skills are **hot-reloaded** -- no Claude Code restart needed. The symlinks point directly into the
repo, so a `git pull` is all it takes.

## Learn More

- **[Context Guide](context-guide.md)** -- How Claude Code's context system works (rules vs skills vs docs)
- **[Design](design.md)** -- Architecture and decision log

## Repo Layout (reference)

```
dotclaude/
  src/
    rules/        # Coding constraints (symlinked to ~/.claude/rules)
    skills/       # On-demand reference (symlinked to ~/.claude/skills)
    user/         # User memory (symlinked to ~/.claude/CLAUDE.md)
    hooks/        # CC hooks (notify-done)
    scripts/      # bootstrap.sh, statusline-command.sh
  scripts/        # handoff-instruction.md (Claude.ai project instruction)
  docs/           # Design docs and guides
```
