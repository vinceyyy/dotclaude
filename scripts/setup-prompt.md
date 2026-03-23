# Setup Prompt

Paste everything below the line into a Claude Code session inside the project you want to configure.

---

Read every file under $DOTCLAUDE_DIR/src/project/ (rules/, plugins.md, mcp-servers/, skills/).
Then analyze THIS project: detect languages, frameworks, package managers, git config, and any existing
CLAUDE.md, .claude/settings.json, or .mcp.json.

Based on what you find, propose a setup plan. For each category, list:
- **Enabled**: what you'd add and a one-line reason
- **Skipped**: everything you're NOT adding and why (so I can override if needed)

1. **Rules** — which rules from src/project/rules/ apply to this project
2. **Plugins** — which plugins from src/project/plugins.md match this project's needs
3. **MCP servers** — which servers from src/project/mcp-servers/ are relevant
4. **Skills** — which skills from src/project/skills/ to copy into .claude/skills/

Wait for my confirmation before writing any files.

After I confirm, create or update these files (merge with existing content, never overwrite
project-specific sections):

- **CLAUDE.md** — add selected rules inline. If the file exists, append rules under a `## Rules`
  section, preserving everything else.
- **.claude/settings.json** — add required marketplaces to `extraKnownMarketplaces` and selected
  plugins to `enabledPlugins`. Merge with any existing keys.
- **.mcp.json** — add selected MCP server configs using `${ENV_VAR}` syntax for secrets. Merge with
  any existing servers.
- **.claude/skills/** — copy selected skill directories from the library.

After writing, print a summary:
- Files created or updated
- Environment variables that need to be set (e.g. `NEON_API_KEY`, `CONTEXT7_API_KEY`) and where to
  get them
- Any manual steps remaining
