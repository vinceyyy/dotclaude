# Claude Code Configuration Kit — Design Document

## Overview

This repo provides a fork-and-own configuration system for Claude Code. It encodes coding standards, workflow patterns,
and learned knowledge into files that Claude Code reads automatically.

**Core Idea**: Rules and skills are symlinked from `~/.claude/` into this repo. Clone it, run bootstrap, make it yours.
Changes are hot-reloaded — no restarts, no manual configuration.

______________________________________________________________________

## Architecture

### How It Works

```
dotclaude/                    ~/.claude/
  src/rules/*.md    ──symlink──→     rules/     (always loaded)
  src/skills/       ──symlink──→     skills/    (loaded on demand)
  src/user/CLAUDE.md──symlink──→     CLAUDE.md  (always loaded, writable)
  src/hooks/        ──referenced──→  settings.json hooks config
```

The bootstrap script (`src/scripts/bootstrap.sh`) creates the symlinks. After that, the repo is the single source of
truth — edits to `src/rules/` or `src/skills/` take effect in the next CC conversation.

### Context Layers

| Layer            | Location             | Loading                  | Purpose                                     |
| ---------------- | -------------------- | ------------------------ | ------------------------------------------- |
| **Constitution** | `src/rules/`         | Always, every session    | Hard constraints CC would violate otherwise |
| **User Memory**  | `src/user/CLAUDE.md` | Always, every session    | Learned patterns, personal preferences      |
| **On-Demand**    | `src/skills/`        | When CC decides relevant | Reference docs, library versions            |
| **Discoverable** | `CLAUDE.md`, `docs/` | When CC reads them       | Project-specific context                    |

See `docs/context-guide.md` for the full educational guide on this model.

### Design Principles

1. **Only encode what CC gets wrong.** Don't repeat general best practices — CC already knows them. Rules should be lean
   (target: ~135 lines total).
2. **Two audiences.** `docs/` is for humans; `CLAUDE.md` and rules are for CC. Neither replaces the other.
3. **Hot-reload over restarts.** Symlinks mean changes propagate immediately.
4. **Git as distribution.** No package manager, no build step. Clone, bootstrap, pull.

______________________________________________________________________

## Components

### Rules (7 files)

Always-loaded constraints that override CC's defaults.

| File               | What it enforces                                  |
| ------------------ | ------------------------------------------------- |
| `coding-style.md`  | Code Field framework, file size limits            |
| `python.md`        | uv, Ruff, pyright, src layout, line length 120    |
| `typescript.md`    | Biome, shadcn/ui, Tailwind v4, Zustand, Lucide    |
| `git.md`           | Feature branches, conventional commits, PR format |
| `security.md`      | No hardcoded secrets, incident protocol           |
| `documentation.md` | Dual audience principle, what goes where          |
| `learning.md`      | Encode/recall/forget cycle for learned patterns   |

### Skills

On-demand reference material, discovered via SKILL.md frontmatter. The public template ships with no skills — add your
own as `src/skills/<name>/SKILL.md`.

### Hooks

| Hook          | Purpose                                                    |
| ------------- | ---------------------------------------------------------- |
| `notify-done` | macOS notification when CC completes a task or needs input |

Configured in `~/.claude/settings.json` — the bootstrap script prints the recommended snippet.

### Two-Phase Workflow

Projects follow a two-phase pattern:

```
Claude.ai (Phone/Web) ──→ PROJECT_SPEC.md ──→ Claude Code (Laptop)
      Ideation               Handoff              Build
```

**Phase 1 — Ideation** (Claude.ai, mobile-friendly):

- Natural conversation to explore the idea, make architecture decisions, define scope
- Paste the handoff instruction (`scripts/handoff-instruction.md`) to generate a `PROJECT_SPEC.md` artifact

**Phase 2 — Build** (Claude Code, laptop):

- CC reads the spec and builds the project
- Uses rules and skills for consistent implementation

The `scripts/handoff-instruction.md` file contains a Claude.ai project instruction that guides ideation and produces the
handoff artifact.

______________________________________________________________________

## File Structure

```
dotclaude/
├── CLAUDE.md                    # CC-facing: repo purpose, setup, file pointers
├── README.md                    # Human-facing: what's included, quick start
├── src/
│   ├── rules/                   # 7 rule files → ~/.claude/rules/
│   │   ├── coding-style.md
│   │   ├── documentation.md
│   │   ├── git.md
│   │   ├── learning.md
│   │   ├── python.md
│   │   ├── security.md
│   │   └── typescript.md
│   ├── skills/                  # Skill directories → ~/.claude/skills/
│   ├── user/                    # User memory → ~/.claude/CLAUDE.md
│   │   └── CLAUDE.md
│   ├── hooks/
│   │   └── notify-done/
│   │       └── notify-done.sh
│   └── scripts/                # Bootstrap and status line
│       ├── bootstrap.sh
│       └── statusline-command.sh
├── scripts/
│   └── handoff-instruction.md   # Claude.ai project instruction
└── docs/
    ├── design.md                # This document
    ├── getting-started.md       # Onboarding guide
    ├── context-guide.md         # Context management education
```

______________________________________________________________________

## Implementation Status

| Component             | Status      | Location                             |
| --------------------- | ----------- | ------------------------------------ |
| Rules (7 files)       | ✅ Complete | `src/rules/`                         |
| User memory template  | ✅ Complete | `src/user/CLAUDE.md`                 |
| Skills directory      | ✅ Complete | `src/skills/`                        |
| notify-done hook      | ✅ Complete | `src/hooks/notify-done/`             |
| Status line           | ✅ Complete | `src/scripts/statusline-command.sh`  |
| Bootstrap script      | ✅ Complete | `src/scripts/bootstrap.sh`           |
| Handoff instruction   | ✅ Complete | `scripts/handoff-instruction.md`     |
| Getting started guide | ✅ Complete | `docs/getting-started.md`            |
| Context guide         | ✅ Complete | `docs/context-guide.md`              |
| Design document       | ✅ Complete | `docs/design.md`                     |

______________________________________________________________________

## Decision Log

| Decision            | Options Considered                                 | Choice               | Rationale                                                           |
| ------------------- | -------------------------------------------------- | -------------------- | ------------------------------------------------------------------- |
| Distribution method | npm package / git submodule / symlinked repo       | Symlinked repo       | Simplest; git pull updates everything; no build step                |
| Knowledge storage   | MCP server / Skills / File-based                   | Skills               | Native to CC, hot-reloaded, simpler than MCP                        |
| Rule philosophy     | Comprehensive / Lean (only what CC gets wrong)     | Lean                 | Reduces context waste; CC already follows most best practices       |
| Documentation model | Single audience / Dual audience                    | Dual                 | Humans need docs/; CC needs CLAUDE.md + rules; both are first-class |
| Notification system | Telegram / macOS native / Web push                 | macOS native         | Zero setup, no API keys, works immediately                          |
| Project handoff     | Verbal / Template / Structured spec                | Structured spec      | Consistent format; CC can parse it reliably                         |
| Context management  | Everything in rules / Three-tier                   | Three-tier           | Balances always-available vs context-window cost                    |
| Learned knowledge   | Skills / Rules / User memory                       | User memory          | Personal patterns don't belong in distributed rules or skills       |
| Ownership model     | Shared upstream / Fork-and-own                     | Fork-and-own         | Users customize freely; no merge conflicts with upstream            |
| Skill format        | Flat .md files / Directory + SKILL.md              | Directory + SKILL.md | CC discovers skills via frontmatter in SKILL.md, not flat files     |

______________________________________________________________________

## Historical Context

This repo evolved from an earlier workflow system that included additional components:

- **Excalidraw MCP** — Visual design integration (removed: better tools emerged)
- **ask-telegram hook** — Telegram bot for async CC prompts (removed: simpler alternatives exist)
- **Self-improving memory** — `/learn` command + `learned/` directory (removed: CC's episodic memory plugins handle
  this)
- **SDV wrapper** — Synthetic data generation tool (removed: was a stub, not needed)
- **Session parser** — Project registry tool (removed: was a stub, not needed)

These were removed during the transition to a distributable configuration kit. The current design focuses on what
generalizes: consistent rules and learned knowledge.

______________________________________________________________________

*Document created: 2024* *Last updated: 2026-02-17* *Status: Public template — complete*
