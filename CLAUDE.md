# dotclaude

Opinionated Claude Code configuration kit. Rules, skills, plugins, and MCP servers — curated once, applied to any
project via a setup prompt.

## First-Time Setup

On every conversation start in this repo, check if the user's Claude Code environment is configured. If not, walk them
through setup.

### 1. Check if already configured

Read `~/.claude/settings.json` and check for:
- `env.DOTCLAUDE_DIR` is set
- `hooks.Notification` exists and points to a `notify-done.sh` inside this repo
- `statusLine` exists and points to a `statusline-command.sh` inside this repo

If all three are present and the paths are valid, skip to "Verify Setup". Otherwise, continue.

### 2. Configure settings.json

Determine the absolute path to this repo (the current working directory).

Show the user what will be added to `~/.claude/settings.json` and ask for confirmation. Merge with any existing
settings — don't overwrite.

The result should include:

```json
{
  "env": {
    "DOTCLAUDE_DIR": "<absolute path to this repo>"
  },
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<absolute path to this repo>/src/user/hooks/notify-done/notify-done.sh",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "<absolute path to this repo>/src/user/scripts/statusline-command.sh"
  }
}
```

Replace `<absolute path to this repo>` with the actual path.

### 3. Verify setup

```bash
cat ~/.claude/settings.json | python3 -m json.tool  # valid JSON
echo $DOTCLAUDE_DIR                                   # should print this repo's path
```

Tell the user they're ready. To configure any project: open a CC session there and paste the contents of
`scripts/setup-prompt.md`.

Point them to `docs/getting-started.md` for details.

## Directory Structure

```
dotclaude/
├── src/
│   ├── project/                    # Copied into projects by the setup prompt
│   │   ├── rules/                  # Coding standards (.md files)
│   │   ├── skills/                 # On-demand reference skills
│   │   ├── mcp-servers/            # MCP configs with ${ENV_VAR} placeholders
│   │   └── plugins.md              # Plugin catalog
│   └── user/                       # Installed into ~/.claude/settings.json
│       ├── hooks/notify-done/      # macOS notification when CC finishes
│       └── scripts/                # Status line script
├── scripts/
│   └── setup-prompt.md             # The prompt to paste into any project
├── docs/                           # Human-readable guides
└── CLAUDE.md                       # You are here
```

## Adding to the Library

| What | Where | Format |
|------|-------|--------|
| New rule | `src/project/rules/<name>.md` | Markdown, concise constraints |
| New MCP server | `src/project/mcp-servers/<name>.json` | JSON with `${ENV_VAR}` for secrets |
| New plugin | `src/project/plugins.md` | Add row to the catalog table |
| New skill | `src/project/skills/<name>/SKILL.md` | Directory with SKILL.md (YAML frontmatter required) |

## Working on This Repo

- Use feature branches (`feat/`, `fix/`, `refactor/`)
- Test changes by pasting `scripts/setup-prompt.md` in another project's CC session
