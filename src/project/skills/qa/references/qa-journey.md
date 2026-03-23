# QA-Journey Mode — Agentic Browser QA

This mode uses a real browser (via Playwright MCP) to walk each journey as a human QA engineer would — taking screenshots, assessing visual quality, flagging issues that deterministic tests can't catch.

**Key difference from `e2e` mode:** No pass/fail assertions. Instead: observations, screenshots, and a qualitative report. The agent uses judgment.

---

## What Agentic QA catches that Playwright tests miss

- Layout broken at certain viewport sizes
- Content that renders but looks wrong (wrong color, cut off, misaligned)
- Loading states that flash or flicker
- Error messages styled to look like success messages
- Buttons present but visually hidden or overlapping
- Empty states that show raw keys or `[object Object]`
- Console errors on pages that otherwise "work"
- Interactions that feel slow or unresponsive

---

## Step 1: Setup

### 1.1 Read journey files

Read all `.md` files in `e2e/`. Build a run list ordered by priority (Critical first).

### 1.2 Set up isolation

Run the isolation protocol (see `isolation.md`) before touching the browser.
Save the isolation context (branch ID, env vars, etc.) for teardown.

### 1.3 Start the app

Check if the app is already running. Read the project's config (package.json scripts, .env, etc.) to determine the
correct port and start command.

```bash
# Example — adapt port and command to the project
curl -s --max-time 3 http://localhost:${APP_PORT}/api/health || echo "not running"
```

If not running, start it pointed at the isolated DB and **save the PID** for clean teardown:

```bash
DATABASE_URL="$ISOLATED_DATABASE_URL" npm run dev &
APP_PID=$!
```

Wait for health check to pass before proceeding.

### 1.4 Authenticate (if needed)

If journeys require an authenticated user, log in once and reuse the session:
1. Navigate to `/login`
2. Snapshot → fill credentials → submit
3. Verify redirect away from `/login`

### 1.5 Prepare screenshots directory

```bash
mkdir -p qa-screenshots/$(date +%Y-%m-%d)
```

Use date-scoped directories so runs don't overwrite each other.

---

## Step 2: Run Journeys

### Parallelism

If subagents are available: spawn one subagent per journey, passing it the journey file content and the screenshot directory path. Each subagent runs its journey independently and returns a findings object. Merge all findings into the final report.

If subagents are not available: run journeys sequentially, Critical priority first.

### Per-journey protocol

For each journey file:

**A. Setup**
- Navigate to the starting URL for this journey
- Snapshot to confirm the page loaded correctly

**B. Walk each step**

For every step in the journey:
1. `browser_snapshot` — always before interacting, to get fresh element refs
2. Perform the action (click, type, navigate)
3. `browser_take_screenshot` — named `{NN}-{journey-slug}-{step-slug}.png`
4. `browser_console_messages` — note any JS errors
5. Assess what you see (see assessment criteria below)

**C. Screenshot naming**

```
qa-screenshots/YYYY-MM-DD/
  01-new-user-purchase-homepage.png
  02-new-user-purchase-product-detail.png
  03-new-user-purchase-cart.png
  ISSUE-new-user-purchase-checkout-layout-broken.png   ← prefix ISSUE for findings
```

**D. Assessment criteria** — for each screenshot, assess:

| Dimension | What to look for |
|---|---|
| **Layout** | Elements overlapping, cut off, or misaligned? Sidebar/header behaving correctly? |
| **Content** | Real data showing, or placeholders/keys/`undefined`? |
| **Hierarchy** | Visual priority makes sense? Most important thing is most prominent? |
| **State** | Loading states present where expected? Errors styled as errors? |
| **Responsiveness** | Does it hold up at this viewport? (test 1440, 768, 375 for Critical journeys) |
| **Console** | Any JS errors, unhandled rejections, or React warnings? |

**E. Record findings**

For each issue found, record:
```
Finding:
  Journey: [journey name]
  Step: [step number and description]
  Screenshot: [filename]
  Issue: [what looks wrong]
  Severity: Critical | High | Medium | Low
  Type: Layout | Content | Visual | Console | Performance | Accessibility
```

Severity guide:
- **Critical** — user cannot complete the journey (button missing, page blank, error shown)
- **High** — journey completes but something important looks wrong or confusing
- **Medium** — minor visual issue, user would notice but proceed
- **Low** — polish issue, most users wouldn't notice

---

## Step 3: Teardown

Run teardown **regardless of whether the run succeeded or failed**.

```bash
# Kill the dev server started by this run (use saved PID, not port scan)
kill $APP_PID 2>/dev/null
```

Then run the isolation teardown (see `isolation.md`).

---

## Step 4: Report

Generate a QA report in `qa-screenshots/YYYY-MM-DD/report.md`:

```markdown
# Agentic QA Report — {date}

## Summary

| Journey | Priority | Status | Issues | Screenshots |
|---------|----------|--------|--------|-------------|
| New user completes purchase | Critical | Issues found | 2 | 01-06 |
| Returning user reorders | High | Clean | 0 | 07-11 |
| Admin manages team | Medium | Blocked | 1 Critical | 12-14 |

Total journeys: 5 | Clean: 2 | Has issues: 2 | Blocked: 1

---

## Findings

### Critical

**[ISSUE] Admin manages team — Step 3: Invite member**
- Screenshot: `ISSUE-admin-team-invite-modal-blank.png`
- Issue: Invite member modal opens but content area is blank. The form fields do not render.
- Console error: `TypeError: Cannot read properties of undefined (reading 'map')`

### High

**[ISSUE] New user completes purchase — Step 5: Checkout**
- Screenshot: `ISSUE-new-user-purchase-checkout-layout-broken.png`
- Issue: At 375px viewport, the "Place Order" button is positioned behind the footer and is not tappable.
- No console errors.

### Medium

**[ISSUE] New user completes purchase — Step 2: Product detail**
- Screenshot: `ISSUE-new-user-purchase-product-detail-image.png`
- Issue: Product image alt text renders as raw key `product.image.alt` instead of the actual alt text.

---

## Console Error Summary

| Page | Error | Journeys affected |
|------|-------|-------------------|
| /admin/team | TypeError: Cannot read properties of undefined | Admin manages team |

---

## Screenshots Index

All screenshots: `qa-screenshots/{date}/`
```

Print the report summary to the conversation, and note the path to the full report.

**Do not attempt to fix any issues.** The report is the output. If the user wants fixes, that's a separate task.
