# Available Plugins

Plugins to consider when setting up a project. Pick only what's relevant.

## Marketplaces

Add these to `extraKnownMarketplaces` in `.claude/settings.json` for their plugins to be available.

**Format** — `extraKnownMarketplaces` values must be objects with a nested `source`; `enabledPlugins` values are `true`:

```json
{
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    },
    "blend360": {
      "source": {
        "source": "github",
        "repo": "Blend360/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true,
    "code-simplifier@claude-plugins-official": true
  }
}
```

Source types: `github` (`repo`), `url` (`url`), `path` (`path`).

| Key | Source | Repo |
|-----|--------|------|
| `superpowers-marketplace` | github | `obra/superpowers-marketplace` |

## Plugins

| Plugin | Marketplace | When to enable | What it does |
|--------|-------------|----------------|--------------|
| `superpowers@superpowers-marketplace` | superpowers-marketplace | Any project | Workflow skills: brainstorming, debugging, TDD, code review, planning |
| `episodic-memory@superpowers-marketplace` | superpowers-marketplace | Any project | Cross-session memory for recalling past decisions |
| `elements-of-style@superpowers-marketplace` | superpowers-marketplace | Projects with significant prose (docs, READMEs) | Writing quality rules |
| `code-simplifier@claude-plugins-official` | built-in | Any project | Code cleanup and simplification before merge |
| `code-review@claude-plugins-official` | built-in | Any project with PRs | Pull request review |
| `feature-dev@claude-plugins-official` | built-in | Any project | Guided feature development with architecture focus |
| `explanatory-output-style@claude-plugins-official` | built-in | Learning/onboarding contexts | Educational insights in responses |
| `ralph-loop@claude-plugins-official` | built-in | Long-running autonomous tasks | Autonomous iteration loop |
| `claude-md-management@claude-plugins-official` | built-in | Any project with CLAUDE.md | CLAUDE.md auditing and improvement |
| `skill-creator@claude-plugins-official` | built-in | Projects that create custom skills | Skill development toolkit |
| `commit-commands@claude-plugins-official` | built-in | Any project with git | Git workflow automation |
| `frontend-design@claude-plugins-official` | built-in | Projects with web UI (React, Vue, etc.) | Distinctive, production-grade frontend interfaces |
| `agent-sdk-dev@claude-plugins-official` | built-in | Projects using Claude Agent SDK | Agent SDK app creation and verification |
| `playwright@claude-plugins-official` | built-in | Projects with E2E tests or browser automation | Browser automation and testing via Playwright |
| `typescript-lsp@claude-plugins-official` | built-in | TypeScript projects | TypeScript language server for type checking and diagnostics |
