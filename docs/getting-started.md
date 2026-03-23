# Getting Started

This repo is a rule library for Claude Code. It holds coding standards, plugin recommendations, MCP server configs, and
skills. You configure each project by pasting a setup prompt into a CC session -- CC reads the library, analyzes the
project, and writes the right config.

## Prerequisites

- Claude Code installed (`curl -fsSL https://claude.ai/install.sh | bash`)
- A Claude Pro, Max, Teams, or Enterprise plan

## One-Time Setup

These steps configure your user-level settings. You only do this once.

### 1. Clone this repo

```bash
git clone <repo-url>
cd dotclaude
```

### 2. Run Claude inside this repo

```bash
claude
```

CC reads `CLAUDE.md` and detects this is the dotclaude repo. It will set up `~/.claude/settings.json` with:

- **`DOTCLAUDE_DIR`** env var pointing to this repo (so the setup prompt can find the library from any project)
- **Notification hook** that plays a sound and shows a macOS notification when CC finishes a task
- **Status line** that shows git branch, model, context usage, and rate limit info

If you already have a `settings.json`, CC merges these keys into it -- it won't overwrite existing config.

### 3. Set environment variables for MCP servers

Add API keys to `~/.zshenv` so they're available in all shells:

```bash
# Context7 — library documentation lookup
export CONTEXT7_API_KEY="your-key-here"

# Neon — serverless Postgres (only if you use Neon)
export NEON_API_KEY="your-key-here"
```

Restart your shell or run `source ~/.zshenv` for changes to take effect.

You only need keys for the MCP servers you plan to use. The setup prompt will tell you which env vars are required
based on the servers it enables for a project.

## Configuring a Project

Go to any project and paste the setup prompt:

```bash
cd ~/Code/your-project
claude
```

Then paste the contents of `scripts/setup-prompt.md` into the CC session. CC will:

1. Read all files under `src/project/` (rules, plugins, MCP servers, skills)
2. Analyze the project (languages, frameworks, existing config)
3. Propose a setup plan -- which rules, plugins, MCP servers, and skills to enable
4. Wait for your confirmation
5. Write the config files (`CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/skills/`)

### What gets written

| File | Content |
|------|---------|
| `CLAUDE.md` | Selected rules inlined under a `## Rules` section (merged with existing content) |
| `.claude/settings.json` | Marketplaces and plugins (merged with existing keys) |
| `.mcp.json` | MCP server configs with `${ENV_VAR}` syntax for secrets (merged with existing servers) |
| `.claude/skills/` | Skill directories copied from the library |

### Re-running the setup

The setup prompt is idempotent. Run it again to pick up new rules or plugins added to the library. CC merges with
existing config -- it won't overwrite project-specific sections.

## Learn More

- **[Context Guide](context-guide.md)** -- How project-level configuration works
- **[Design](design.md)** -- Architecture and decision log
