# Managing Context Effectively with Claude Code

Claude Code reads instructions from multiple locations, each with different loading behavior and cost to your context
window. Understanding these layers lets you put the right information in the right place — so CC always has what it
needs without wasting tokens on what it doesn't.

______________________________________________________________________

## Context Layers

| Layer            | Location              | Behavior                             | What belongs here                                                   |
| ---------------- | --------------------- | ------------------------------------ | ------------------------------------------------------------------- |
| **Constitution** | `~/.claude/rules/`    | Always loaded, every conversation    | Hard constraints, choices CC gets wrong without instruction         |
| **User Memory**  | `~/.claude/CLAUDE.md` | Always loaded, every conversation    | Learned patterns, personal preferences (CC maintains automatically) |
| **On-Demand**    | `~/.claude/skills/`   | Loaded when CC decides it's relevant | Reference documentation, patterns, library versions                 |
| **Discoverable** | `docs/`, `CLAUDE.md`  | CC reads when needed                 | Project-specific architecture, build commands, setup guides         |

### Constitution (Rules)

Rules are injected into every conversation automatically. This makes them the most powerful layer — and the most
expensive. Every line you add here consumes context window in every session, whether or not it's relevant. Reserve this
layer for hard constraints that CC would violate without explicit instruction.

### User Memory

`~/.claude/CLAUDE.md` is always loaded and writable. CC maintains it automatically using the encode/recall/forget cycle
(see `src/rules/learning.md`). This is where personal learned patterns accumulate over time — things CC discovered
during development that might apply to future projects. Unlike rules, this content is personal and evolves organically.

### On-Demand (Skills)

Skills are loaded selectively. CC discovers them via YAML frontmatter in `SKILL.md` files and loads them when it
determines they're relevant to the current task. This is the right place for reference material that matters in some
sessions but not all — like library-specific guidance, code patterns, or deployment conventions.

### Discoverable (Project Files)

CLAUDE.md and docs/ files live in the project repo. CC reads them when it needs project-specific context — build
commands, architecture decisions, folder layout. These are free until accessed, and they travel with the repo so every
collaborator benefits.

______________________________________________________________________

## What Belongs in Each Layer

### Rules (Constitution) — Keep Lean

Rules should contain only things CC gets wrong by default. If CC already does something correctly without instruction,
the rule is wasting context.

- **Bad**: "Use snake_case for Python functions" — CC already follows PEP 8
- **Good**: "Use Biome, not ESLint" — CC defaults to ESLint without this
- **Bad**: "Write unit tests for new features" — CC does this when asked
- **Good**: "Use uv for all Python dependency management, never pip" — CC defaults to pip

Target **~135 lines total** across all rule files. If you're well above that, audit aggressively. Most users can express
their hard constraints in 100-150 lines.

Ask yourself for every line: "Would CC do the wrong thing without this?" If the answer is no, delete it.

### Skills (On-Demand)

Skills hold reference material that CC should look up rather than guess. Because they're loaded selectively, they don't
cost you context in sessions where they're irrelevant.

Good candidates for skills:

- Technology choices and version pinning (e.g., "React 19 with Server Components")
- Code patterns specific to your workflow (e.g., "All API clients use this retry wrapper")
- Library-specific guidance (e.g., "Use pydantic-ai, not LangChain")
- Deployment and infrastructure conventions

Keep each skill file focused on one topic. A skill file that covers everything is just a rule file with extra steps.

### Project Files (Discoverable)

These live in the repo and provide project-specific context.

**CLAUDE.md** is the entry point. Include:

- Build and test commands (`npm run dev`, `uv run pytest`)
- Project constraints and non-obvious decisions
- File layout overview if the structure is unusual

**docs/** holds deeper material:

- Architecture decision records
- Setup guides for new contributors
- API documentation
- Integration guides

CC reads these on demand, so length is less of a concern — but clarity still matters.

______________________________________________________________________

## Session Management

Context accumulates during a session. Long sessions with many file reads and tool calls will eventually degrade CC's
ability to hold the full picture. Three tools help:

- **`/clear`** — Resets the conversation entirely. Rules reload automatically, skills and project files do not. Use this
  between unrelated tasks in the same project.
- **`/compact`** — Summarizes the conversation so far, freeing context while preserving key decisions. Use this at
  natural breakpoints during long sessions (after finishing a feature, before starting a refactor).
- **Subagents** — CC can spawn a subagent for isolated research (reading a large file, exploring an unfamiliar
  codebase). The subagent's context is discarded when it returns results, keeping the parent session clean.

A good rule of thumb: if you've been working for 30+ minutes on varied tasks, `/compact` is probably overdue.

______________________________________________________________________

## Writing Effective Instructions

The goal is to encode **your specific choices only**. CC has strong defaults — your job is to override the ones that
don't match your preferences, not to restate general best practices.

### Principles

1. **Specific, not universal.** Don't tell CC how to write good code. Tell it which tools and conventions you've chosen.
2. **Actionable, not philosophical.** "Prefer composition over inheritance" is too vague to change behavior. "All React
   state management uses Zustand, not Redux" changes behavior.
3. **Testable.** For every instruction, ask: "Would CC do the wrong thing without this?" If you can't think of a
   concrete scenario, the instruction is probably noise.

### Good vs. Bad Examples

| Bad (Remove It)                                   | Good (Keep It)                                   | Why                                                     |
| ------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------- |
| "Use descriptive variable names"                  | *(just delete it)*                               | CC already writes clear names                           |
| "Always handle errors"                            | *(just delete it)*                               | CC already adds error handling                          |
| "Use ESLint for linting"                          | "Use Biome, not ESLint"                          | CC defaults to ESLint — you chose differently           |
| "Python projects should use virtual environments" | "Use uv for dependency management, never pip"    | CC knows about venvs but defaults to pip without this   |
| "Write clean, maintainable code"                  | *(just delete it)*                               | This changes nothing about CC's behavior                |
| "Use TypeScript for type safety"                  | "Strict mode required, no `any` — use `unknown`" | CC uses TS already; the specific strictness rule is new |

### The Deletion Test

Go through your rules once a month. For each line, remove it temporarily and see if CC's behavior changes. If nothing
changes, the line was dead weight. Your future self — staring at a context window limit during a complex refactor — will
thank you for the space.

______________________________________________________________________

*Guide version: 1.1* *From: dotclaude/docs/context-guide.md*
