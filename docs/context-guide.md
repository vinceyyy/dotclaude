# Managing Context Effectively with Claude Code

Claude Code reads instructions from multiple locations. Understanding where config lives helps you put the right
information in the right place -- so CC has what it needs without wasting tokens.

______________________________________________________________________

## Configuration Model

This system uses **project-level configuration**. Each project gets its own rules, plugins, MCP servers, and skills.
The library (`src/project/`) is the source of truth for what's available; the setup prompt copies the relevant subset into
each project.

### Where Config Lives

| Location | Scope | What lives here | How it's loaded |
|----------|-------|-----------------|-----------------|
| `CLAUDE.md` (project root) | Per-project | Rules (inlined), build commands, project context | Always loaded, every session |
| `.claude/settings.json` (project) | Per-project | Plugins, marketplace registrations | Always loaded |
| `.mcp.json` (project root) | Per-project | MCP server configs | Always loaded |
| `.claude/skills/` (project) | Per-project | On-demand reference material | Loaded when CC decides relevant |
| `~/.claude/settings.json` (user) | All projects | Hooks, status line, DOTCLAUDE_DIR | Always loaded |

### The Library vs. Projects

The library (`src/project/`) in this repo is a reference collection. It is **not** installed globally. When you run the
setup prompt in a project, CC reads the library and copies relevant pieces into the project's own config files.

This means:

- **Different projects get different rules.** A Python-only project doesn't get TypeScript rules.
- **Projects own their config.** Updating the library doesn't change existing projects.
- **No global state.** The only user-level config is hooks, status line, and DOTCLAUDE_DIR in `~/.claude/settings.json`.

______________________________________________________________________

## What Belongs Where

### CLAUDE.md (Project Rules)

Rules are inlined into each project's CLAUDE.md. Because they're loaded in every session, keep them lean. Only encode
things CC would get wrong without instruction.

- **Bad**: "Use snake_case for Python functions" -- CC already follows PEP 8
- **Good**: "Use Biome, not ESLint" -- CC defaults to ESLint without this
- **Bad**: "Write unit tests for new features" -- CC does this when asked
- **Good**: "Use uv for all Python dependency management, never pip" -- CC defaults to pip

Ask yourself for every line: "Would CC do the wrong thing without this?" If not, delete it.

### .claude/settings.json (Plugins)

Plugins extend CC's behavior. The setup prompt selects plugins based on the project's needs and writes them into the
project-level settings file. See `src/project/plugins.md` for the full catalog.

### .mcp.json (MCP Servers)

MCP servers give CC access to external services. Configs use `${ENV_VAR}` syntax for secrets so credentials stay in
the environment. See `src/project/mcp-servers/` for available servers.

### .claude/skills/ (On-Demand Reference)

Skills are loaded selectively. CC discovers them via YAML frontmatter in `SKILL.md` files and loads them when relevant.
Good for reference material that matters in some sessions but not all -- like library-specific guidance or API patterns.

______________________________________________________________________

## Session Management

Context accumulates during a session. Long sessions will eventually degrade CC's ability to hold the full picture.
Three tools help:

- **`/clear`** -- Resets the conversation entirely. Rules reload automatically, skills and project files do not. Use
  this between unrelated tasks in the same project.
- **`/compact`** -- Summarizes the conversation so far, freeing context while preserving key decisions. Use this at
  natural breakpoints during long sessions.
- **Subagents** -- CC can spawn a subagent for isolated research. The subagent's context is discarded when it returns
  results, keeping the parent session clean.

A good rule of thumb: if you've been working for 30+ minutes on varied tasks, `/compact` is probably overdue.

______________________________________________________________________

## Writing Effective Rules

The goal is to encode **your specific choices only**. CC has strong defaults -- your job is to override the ones that
don't match your preferences.

### Principles

1. **Specific, not universal.** Don't tell CC how to write good code. Tell it which tools and conventions you've chosen.
2. **Actionable, not philosophical.** "Prefer composition over inheritance" is too vague. "All React state management
   uses Zustand, not Redux" changes behavior.
3. **Testable.** For every instruction, ask: "Would CC do the wrong thing without this?" If you can't think of a
   concrete scenario, the instruction is probably noise.

### Good vs. Bad Examples

| Bad (Remove It) | Good (Keep It) | Why |
|-----------------|----------------|-----|
| "Use descriptive variable names" | *(just delete it)* | CC already writes clear names |
| "Always handle errors" | *(just delete it)* | CC already adds error handling |
| "Use ESLint for linting" | "Use Biome, not ESLint" | CC defaults to ESLint -- you chose differently |
| "Python projects should use virtual environments" | "Use uv for dependency management, never pip" | CC defaults to pip |
| "Write clean, maintainable code" | *(just delete it)* | This changes nothing about CC's behavior |
| "Use TypeScript for type safety" | "Strict mode required, no `any` -- use `unknown`" | The specific strictness rule is new |

### The Deletion Test

Go through your rules once a month. For each line, remove it temporarily and see if CC's behavior changes. If nothing
changes, the line was dead weight.

______________________________________________________________________

*Guide version: 2.0*
