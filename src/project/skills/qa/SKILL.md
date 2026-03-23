---
name: qa
description: "E2E testing and agentic QA for TypeScript UI projects: write Playwright tests, define user journeys, and run agentic QA with real browser execution."
---

# Testing Skill

Two approaches to E2E quality, one skill.

**Traditional E2E testing** — write and run Playwright tests the way an engineer would. Test features, pages, and flows as they're built. No ceremony required.

**Agentic QA** — define the journeys that matter to real users, then let an agent walk them in a browser with screenshots and judgment. Catches what assertions can't.

This skill is for **TypeScript UI projects** using Playwright. For unit tests or API tests, use the project's test framework directly.

**Requires:** `playwright@claude-plugins-official` plugin enabled in `.claude/settings.json`.

## Modes

| Mode | When to use | Read next |
|---|---|---|
| **`e2e`** | Write/run Playwright E2E tests | [references/e2e.md](references/e2e.md) |
| **`define-journey`** | Discover and define user journeys for agentic QA | [references/define-journey.md](references/define-journey.md) |
| **`qa-journey`** | Run agentic QA with real browser (requires journey definitions) | [references/qa-journey.md](references/qa-journey.md) |

**If the user doesn't specify a mode:**
- User wants E2E tests written or run → `e2e`
- User wants the app visually checked / agentic QA → check for journey definitions in `e2e/*.md`; if none, start with `define-journey`, then `qa-journey`
- User wants both → `e2e` for deterministic tests, then `define-journey` → `qa-journey` for agentic QA

---

## Journey Definitions

Journey definitions are plain-language `.md` files that describe what a user is trying to accomplish — the steps, expected outcomes, priority, and edge cases. They exist for **agentic QA**: the QA agent reads them to know what to walk through in the browser.

They live in `e2e/` and follow this format:

```markdown
# Journey: [User type] [accomplishes goal]

**Priority:** Critical | High | Medium
**User type:** guest | authenticated | admin | [other]
**Why it matters:** [business/user impact]

## Steps

1. [Action] → [expected outcome]
2. [Action] → [expected outcome]
...

## Success criteria

- [What "done" looks like from the user's perspective]
- [Any data that should exist after the journey]

## Edge cases (optional)

- [Known edge case and expected behavior]
```

Journey definitions are **not required for `e2e` mode**. Traditional E2E tests are written by engineers as features are built, not from a pre-planned journey map.

---

## Shared: Data Isolation Protocol

Both `e2e` and `qa-journey` modes require isolated state. Read [references/isolation.md](references/isolation.md) for full details.

The short version:
1. **Create** an isolated DB/state before the run (branch, schema, seed)
2. **Run** tests/QA against that isolated state
3. **Teardown** always — even if the run fails

---

## Parallelism

Where possible, parallelize:
- In `e2e` mode: Playwright handles parallelism natively via workers
- In `qa-journey` mode: if subagents are available, spawn one subagent per journey and merge reports at the end; otherwise run journeys sequentially

Always set up isolation **before** spawning parallel work, and teardown **after** all parallel work completes.
