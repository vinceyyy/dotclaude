# dotclaude

A fork-and-own configuration system for Claude Code. Rules, memory, and skills — version-controlled in one repo,
symlinked into `~/.claude/`. Clone it, run bootstrap, make it yours.

## Quick Start

```bash
curl -fsSL https://claude.ai/install.sh | bash
git clone <repo-url>
cd dotclaude
claude --dangerously-skip-permissions
```

Claude Code reads this repo's `CLAUDE.md` and walks you through setup. For manual setup, see `docs/getting-started.md`.

## What You Get

**Rules** — coding standards enforced in every session. The 7 included rules cover Python (uv, Ruff, pyright),
TypeScript (Biome, shadcn/ui, Tailwind v4), git workflow, security, documentation, coding style, and a learning
mechanism. Edit them, add your own, delete the ones that don't apply to you.

**User Memory** — CC's long-term memory across projects. As you work, CC encodes reusable patterns into
`~/.claude/CLAUDE.md` as one-line cues. On new projects, it scans those cues and recalls relevant context. Stale
patterns are pruned automatically (capped at 50 entries). Inspired by how the brain works: lightweight cues trigger
recall, not full replays.

**Skills** — on-demand reference material CC consults when relevant, discovered via YAML frontmatter. The public
template ships with no skills — add your own as `src/skills/<name>/SKILL.md` for things like brand guidelines, API
references, or library-specific patterns.

**Plugins** — eight recommended plugins configured in `settings.json`: superpowers (TDD, debugging, planning),
episodic-memory (backs the recall mechanism), elements-of-style, code-simplifier, code-review, feature-dev,
explanatory-output-style, and ralph-loop.

**Developer Experience** — notification hook (sound + macOS alert when CC finishes) and status line (branch, model,
context usage, rate limits).

## How It Works

Everything lives under `src/` — this is what gets distributed to Claude Code via symlinks:

```
src/
  rules/        → ~/.claude/rules/       Always loaded. Your coding standards.
  skills/       → ~/.claude/skills/      Loaded on demand. Reference material.
  user/         → ~/.claude/CLAUDE.md    Always loaded. CC reads and writes this.
  hooks/                                 Notification hook, referenced from settings.json.
  scripts/                               Bootstrap and status line.
```

The `src/scripts/bootstrap.sh` script creates the symlinks. After that, changes are hot-reloaded — edit a file, CC picks
it up in the next conversation.

Outside `src/`, the repo contains `docs/` (human-readable guides) and `scripts/` (manual actions like the handoff
instruction for Claude.ai).

## Fork and Own

This repo is a starting point, not a shared upstream. Once cloned:

- Tune `src/rules/` to your coding standards
- Add skills in `src/skills/` for your libraries and conventions
- Let `src/user/CLAUDE.md` accumulate your learned patterns over time
- Commit and push to keep your config versioned

## Two-Phase Workflow

Ideate in Claude.ai, build in Claude Code. At the end of a Claude.ai conversation, paste the prompt from
`scripts/handoff-instruction.md` to generate a project spec. Save it to your project folder and tell Claude Code to read
it.

## Documentation

- **[Getting Started](docs/getting-started.md)** — Setup details and manual setup option
- **[Context Guide](docs/context-guide.md)** — How rules, skills, and docs layers work
- **[Design](docs/design.md)** — Architecture and decision log
