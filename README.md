# dotclaude

Opinionated Claude Code configuration. Rules, skills, plugins, and MCP servers — curated once, applied to any project
via a setup prompt.

## Quick Start

```bash
git clone https://github.com/vinceyyy/dotclaude.git ~/dotclaude
cd ~/dotclaude
claude
```

Claude Code reads the CLAUDE.md and sets up your user-level config (notification hook, status line). Then for any
project:

1. Open Claude Code in the project directory
2. Paste the contents of `scripts/setup-prompt.md`
3. CC analyzes your project, proposes which rules/plugins/MCP servers to enable, and writes the config after you confirm

Re-run the setup prompt any time to pick up new rules or plugins from dotclaude updates.

## What's Included

### Project-Level (`src/project/`)

Content CC selects and copies into each project based on its tech stack:

**Rules** — coding standards for Python (uv, Ruff, pyright), TypeScript (Biome, shadcn/ui, Tailwind v4), git workflow,
security, documentation, coding style, Context7 usage, and GitHub branch rulesets. CC auto-detects which apply.

**Plugins** — catalog of recommended Claude Code plugins with guidance on when to enable each. Includes superpowers,
episodic-memory, code-review, feature-dev, commit-commands, and more.

**MCP Servers** — pre-configured server definitions (Context7, Neon) ready to merge into a project's `.mcp.json`.
Secrets use `${ENV_VAR}` syntax so credentials stay in the environment.

**Skills** — on-demand reference material CC consults when relevant: Context7 MCP usage guide and E2E journey testing
(Playwright).

### User-Level (`src/user/`)

Installed once into `~/.claude/settings.json` during first-time setup:

**Notification hook** — plays a sound and shows a macOS notification when CC finishes a task.

**Status line** — shows git branch, model, context usage, and rate limit info.

## Adding Your Own

| What | Where | Format |
|------|-------|--------|
| Rule | `src/project/rules/<name>.md` | Markdown constraints CC should follow |
| Plugin | `src/project/plugins.md` | Add a row to the catalog table |
| MCP server | `src/project/mcp-servers/<name>.json` | JSON with `${ENV_VAR}` for secrets |
| Skill | `src/project/skills/<name>/SKILL.md` | Directory with YAML frontmatter |

## Documentation

- **[Getting Started](docs/getting-started.md)** — Detailed setup and first-use walkthrough
- **[Context Guide](docs/context-guide.md)** — How project-level configuration works
- **[Design](docs/design.md)** — Architecture and decision log
