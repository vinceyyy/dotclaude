# dotclaude -- Design Document

## Overview

This repo is a rule library for Claude Code project configuration. It contains coding standards, plugin recommendations,
MCP server configs, and skills in a central location. A setup prompt copies the relevant subset into each project.

**Core Idea**: The library is a curated source of truth. Projects get their own copies of the rules they need, configured
at the project level. No global installation, no runtime dependency on this repo.

______________________________________________________________________

## Architecture

### How It Works

```
dotclaude/                               Target Project/
  src/project/                             CLAUDE.md          (rules inlined)
    rules/*.md         ──setup prompt──→   .claude/settings.json  (plugins)
    plugins.md                             .mcp.json          (MCP servers)
    mcp-servers/*.json                     .claude/skills/    (skills copied)
    skills/
  src/user/                              ~/.claude/
    hooks/             ──settings.json──→   settings.json hooks
    scripts/                               statusline config
```

The setup prompt (`scripts/setup-prompt.md`) is pasted into a CC session inside the target project. CC reads the library,
analyzes the project, proposes a config plan, and writes the files after confirmation.

### Configuration Levels

| Level | Location | What lives here | How it gets there |
|-------|----------|-----------------|-------------------|
| **Project** | `CLAUDE.md`, `.claude/`, `.mcp.json` | Rules, plugins, MCP servers, skills | Setup prompt copies from library |
| **User** | `~/.claude/settings.json` | Hooks, status line, DOTCLAUDE_DIR | First-time setup inside this repo |
| **Library** | This repo | Source of truth for all available config | Not installed anywhere |

### Design Principles

1. **Project-level config.** Rules live in the project, not globally. Different projects get different rules.
2. **Only encode what CC gets wrong.** Don't repeat general best practices -- CC already knows them.
3. **Auto-detect, don't prescribe.** CC analyzes the project and proposes which rules apply.
4. **Copy, don't link.** Projects own their config. Updating the library doesn't silently change existing projects.

______________________________________________________________________

## Components

### Rules (8 files)

Coding standards that get inlined into a project's CLAUDE.md.

| File | What it enforces |
|------|------------------|
| `coding-style.md` | Code Field framework, file size limits |
| `python.md` | uv, Ruff, pyright, src layout, line length 120 |
| `typescript.md` | Biome, shadcn/ui, Tailwind v4, Zustand, Lucide |
| `git.md` | Feature branches, conventional commits, PR format |
| `security.md` | No hardcoded secrets, incident protocol |
| `documentation.md` | Dual audience principle, what goes where |
| `context7.md` | Use Context7 MCP for library documentation |
| `github-rulesets.md` | Branch protection and CI/CD patterns |

### Plugins Catalog

`src/project/plugins.md` lists available plugins with marketplace info and guidance on when to enable each one. The setup
prompt uses this to propose plugins for the project's `.claude/settings.json`.

### MCP Servers

Pre-configured server definitions in `src/project/mcp-servers/`:

| File | Server | Purpose |
|------|--------|---------|
| `context7.json` | Context7 | Library documentation lookup |
| `neon.json` | Neon | Serverless Postgres management |

Secrets use `${ENV_VAR}` syntax. The setup prompt tells the user which env vars need to be set.

### Skills

On-demand reference material in `src/project/skills/`. Each skill is a directory with a `SKILL.md` file containing YAML
frontmatter for discovery. The setup prompt copies relevant skills into the project's `.claude/skills/`.

### User Toolbox

User-level tools in `src/user/` that apply to all CC sessions:

| Component | Purpose |
|-----------|---------|
| `hooks/notify-done/` | macOS notification when CC completes a task |
| `scripts/statusline-command.sh` | Git branch, model, context, rate limits in status bar |

Configured via `~/.claude/settings.json` -- not part of the library distribution.

______________________________________________________________________

## File Structure

```
dotclaude/
├── CLAUDE.md                          # CC-facing: repo purpose, working conventions
├── README.md                          # Human-facing: what's included, quick start
├── src/
│   ├── project/
│   │   ├── rules/                     # 8 rule files (copied into project CLAUDE.md)
│   │   │   ├── coding-style.md
│   │   │   ├── context7.md
│   │   │   ├── documentation.md
│   │   │   ├── git.md
│   │   │   ├── github-rulesets.md
│   │   │   ├── python.md
│   │   │   ├── security.md
│   │   │   └── typescript.md
│   │   ├── plugins.md                 # Plugin catalog with marketplace info
│   │   ├── mcp-servers/               # MCP server configs (merged into .mcp.json)
│   │   │   ├── context7.json
│   │   │   └── neon.json
│   │   └── skills/                    # Skill directories (copied into .claude/skills/)
│   │       └── context7-mcp/
│   └── user/
│       ├── hooks/
│       │   └── notify-done/
│       │       └── notify-done.sh
│       └── scripts/
│           └── statusline-command.sh
├── scripts/
│   └── setup-prompt.md                # Paste into any project to configure it
└── docs/
    ├── design.md                      # This document
    ├── getting-started.md             # Onboarding guide
    └── context-guide.md               # How project-level config works
```

______________________________________________________________________

## Decision Log

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| Distribution method | Symlinked repo / npm package / prompt-driven copy | Prompt-driven copy | Projects own their config; no runtime dependency on this repo |
| Config level | User-level (~/.claude/) / Project-level | Project-level | Different projects need different rules; global config is too blunt |
| Rule selection | Manual / Auto-detect by CC | Auto-detect | CC analyzes the project and proposes relevant rules; less manual work |
| Knowledge storage | MCP server / Skills / File-based | Skills | Native to CC, hot-reloaded, simpler than MCP |
| Rule philosophy | Comprehensive / Lean (only what CC gets wrong) | Lean | Reduces context waste; CC already follows most best practices |
| Documentation model | Single audience / Dual audience | Dual | Humans need docs/; CC needs CLAUDE.md + rules; both are first-class |
| Notification system | Telegram / macOS native / Web push | macOS native | Zero setup, no API keys, works immediately |
| Context management | Everything in rules / Layered | Layered | Rules inline in CLAUDE.md, plugins in settings, MCP in .mcp.json |
| Ownership model | Shared upstream / Fork-and-own | Fork-and-own | Users customize freely; no merge conflicts with upstream |
| Skill format | Flat .md files / Directory + SKILL.md | Directory + SKILL.md | CC discovers skills via frontmatter in SKILL.md |
| Repo discovery | Symlinks / env var (DOTCLAUDE_DIR) | Env var | No filesystem magic; explicit, portable, easy to verify |

______________________________________________________________________

## Historical Context

This repo evolved from an earlier workflow system that included additional components:

- **Excalidraw MCP** -- Visual design integration (removed: better tools emerged)
- **ask-telegram hook** -- Telegram bot for async CC prompts (removed: simpler alternatives exist)
- **SDV wrapper** -- Synthetic data generation tool (removed: was a stub, not needed)
- **Session parser** -- Project registry tool (removed: was a stub, not needed)

The current design focuses on a curated library that gets applied per-project via a setup prompt.

______________________________________________________________________

*Document created: 2024* *Last updated: 2026-03-22*
