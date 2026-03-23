# Define-Journey Mode — Discover and Define User Journeys for Agentic QA

This mode produces the journey definition files that `qa-journey` mode needs to run.

Run this mode when: the user wants agentic QA but no journey definitions exist yet, definitions seem incomplete, or the user wants to review what's covered.

---

## Step 1: Read the Repo

Read in this order, stopping when you have a clear picture of the product:

1. **`README.md`** — product description, key features, user-facing capabilities
2. **`docs/`** — all `.md` files directly inside (not deeply nested). These are the evergreen design docs that describe intended behavior
3. **`CONTRIBUTING.md`**, `CHANGELOG.md` if present — reveals major feature areas and recent changes
4. **Routes/pages** — scan (don't deeply read) `app/routes/`, `pages/`, `src/router/`, or equivalent to get a complete list of surfaces
5. **API entry points** — scan endpoint definitions to understand what actions are possible

### What you're extracting

- Who are the distinct user types? (guest, authenticated, admin, different roles)
- What does each user type come to accomplish?
- Which paths are business-critical (broken = serious)?
- What are the natural sequences — what does a user do *after* doing X?

---

## Step 2: Formulate Candidate Journeys

Synthesize what you read into candidate journeys. Group by user type. For each:

```
Journey: [User type] [accomplishes goal]
Steps: [step 1] → [step 2] → ... → [final outcome]
Why it matters: [impact if broken]
Priority: Critical | High | Medium
```

Mark **Critical** only paths where breakage would directly block core product value (e.g., can't sign up, can't complete a purchase, can't access main feature).

---

## Step 3: Check for Existing Journey Definitions

Before presenting, check if `e2e/` already has journey definition files (`.md`):
- If yes, read existing files and note which journeys are already defined
- Present new candidates separately from existing ones
- Flag any existing journeys that look stale or incomplete

---

## Step 4: Present for Review

Show the user a structured list:

```
## Existing journey definitions (already in e2e/)
- new-user-signs-up.md
- user-completes-purchase.md

## Candidate journeys I discovered
[Journey 1 summary with priority]
[Journey 2 summary with priority]
...

## Questions for you
1. Do these look right? Anything to remove or change?
2. Are there important journeys I missed?
3. Any that are out of scope for now?
4. Are there any user types I didn't account for?
```

**Do not write any files until the user responds.** This conversation is the most important part.

---

## Step 5: Write Journey Definition Files

After the user approves (or adjusts) the list, write one file per journey into `e2e/`:

**Filename:** `[user-type]-[accomplishes-goal].md`
Examples: `new-user-completes-purchase.md`, `admin-manages-team.md`, `guest-views-public-content.md`

Use the journey definition format from the main SKILL.md.

```markdown
# Journey: New user completes first purchase

**Priority:** Critical
**User type:** unauthenticated → creates account during flow
**Why it matters:** Core revenue path — if broken, no one can buy

## Steps

1. Arrives on homepage → sees product listings
2. Clicks a product → sees product detail page
3. Clicks "Add to cart" → cart count updates to 1
4. Clicks "Checkout" → prompted to create account or guest checkout
5. Fills in shipping and payment → sees order summary
6. Confirms order → lands on order confirmation page with order number

## Success criteria

- Order confirmation page shows with a valid order number
- Order exists in the database
- Confirmation email is queued (if applicable)

## Edge cases

- Guest checkout: skip account creation, still see confirmation
- Out-of-stock item: "Add to cart" is disabled, user sees stock message
```

---

## Step 6: Optional — Discover Missing Journeys

After writing the approved definitions, offer to do a gap check:

> "Want me to do a quick scan to see if there are any significant flows in the app that don't have a corresponding journey definition yet? This can catch things that weren't in the docs."

If yes: scan route files and API endpoints, cross-reference against written definitions, and report any significant surfaces that aren't covered. Present as candidates — don't write files without approval.

This is the only "exploration" in this skill: it's bounded (looking for gaps in definitions, not free-form exploration) and always requires approval before writing.
