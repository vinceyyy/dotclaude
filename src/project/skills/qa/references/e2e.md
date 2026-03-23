# E2E Mode — Write and Run Playwright Tests

Write and run Playwright E2E tests the way an engineer would — test features, pages, and flows as they're built.

---

## Step 1: Understand What to Test

Read the app to understand what needs E2E coverage. Check routes/pages, API endpoints, README/docs, and any existing tests. If journey definition files exist in `e2e/*.md` (from `define-journey` mode), they're useful context but not required input.

---

## Step 2: Check Existing Infrastructure

Before writing, check what already exists:

```bash
ls e2e/helpers/          # existing actions, fixtures, selectors
cat playwright.config.ts  # workers, timeout, base URL, storage state
ls e2e/*.spec.ts 2>/dev/null  # any tests already written
```

Match the existing style. If no infrastructure exists, scaffold it.

---

## Step 3: Set Up Isolation

Run the isolation protocol (see `isolation.md`) before running any tests.
For writing tests, you just need the config to point at the right environment.

---

## Step 4: Write Tests

### File structure

```
e2e/
├── new-user-completes-purchase.md        ← journey definition (for qa-journey mode)
├── new-user-completes-purchase.spec.ts   ← E2E test
├── admin-manages-team.spec.ts
├── smoke/
│   └── critical-paths.spec.ts           ← shallow-and-wide deploy gate
└── helpers/
    ├── actions.ts       ← reusable multi-step user actions
    ├── fixtures.ts      ← test data setup/teardown
    └── selectors.ts     ← shared selectors (optional)
```

### E2E test anatomy

```typescript
// e2e/new-user-completes-purchase.spec.ts

import { test, expect } from '@playwright/test';
import { completeCheckout, addToCart } from './helpers/actions';
import { createTestProduct } from './helpers/fixtures';

test.describe('New user completes first purchase', () => {

  // Happy path — mirrors the journey steps exactly
  test('browses, adds to cart, and checks out as guest', async ({ page }) => {
    const product = await createTestProduct();

    await page.goto('/');
    await page.click(`[data-testid="product-${product.id}"]`);
    await expect(page).toHaveURL(`/products/${product.id}`);

    await addToCart(page, product);
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');

    await completeCheckout(page, { asGuest: true, product });

    await expect(page).toHaveURL('/order-confirmation');
    await expect(page.locator('h1')).toContainText('Order confirmed');
  });

  // Edge cases from the journey definition
  test('cannot add out-of-stock item to cart', async ({ page }) => {
    const product = await createTestProduct({ stock: 0 });
    await page.goto(`/products/${product.id}`);
    await expect(page.locator('[data-testid="add-to-cart"]')).toBeDisabled();
    await expect(page.locator('[data-testid="stock-message"]')).toBeVisible();
  });

});
```

### Naming rules

| Thing | Pattern | Example |
|---|---|---|
| File | `[journey-slug].spec.ts` | `new-user-completes-purchase.spec.ts` |
| `describe` block | Journey name verbatim | `'New user completes first purchase'` |
| Happy path test | Describes the full outcome | `'browses, adds to cart, and checks out as guest'` |
| Edge case test | Describes the specific behavior | `'cannot add out-of-stock item to cart'` |

Never name a test after a UI element or page. Name it after what the user is trying to do.

### Helpers pattern

Keep helpers named after user intent:

```typescript
// helpers/actions.ts

// Named after what the user does
export async function login(page, credentials) { ... }
export async function addToCart(page, product) { ... }
export async function completeCheckout(page, options) { ... }

// NOT this
// export async function clickSubmitButton(page) { ... }
// export async function fillCheckoutForm(page) { ... }
```

State setup via fixtures, never via UI navigation:

```typescript
// helpers/fixtures.ts

// Set up state programmatically
export async function createAuthenticatedUser() {
  return db.users.create({ email: `test-${Date.now()}@example.com`, ... });
}

// Never do this for setup — it tests signup, not sets up state
// export async function signUpNewUser(page) {
//   await page.goto('/signup');
//   ...
// }
```

### Smoke suite

The smoke suite is a shallow-and-wide subset of E2E tests used as a go/no-go deploy gate. It is the earliest execution of E2E tests in the pipeline — its job is to catch catastrophic breakage fast, not to assess overall quality.

Pull one assertion per critical journey — the single most important check that proves the path works. Keep the entire suite under 2 minutes.

```typescript
// smoke/critical-paths.spec.ts
// Shallow-and-wide deploy gate — one check per critical journey
// Must complete in < 2 minutes. Failure blocks deploy.

test('user can sign in', async ({ page }) => { ... });
test('user can complete a purchase', async ({ page }) => { ... });
test('admin can access admin panel', async ({ page }) => { ... });
```

Run smoke on every deploy. Run the full E2E suite on PRs and nightly.

---

## Step 5: Run and Verify

```bash
# Run a single E2E test
npx playwright test e2e/new-user-completes-purchase.spec.ts

# Run all E2E tests
npx playwright test e2e/

# Run smoke suite
npx playwright test e2e/smoke/

# Run full suite
npx playwright test
```

Playwright runs workers in parallel by default — one worker per test file.
If a test fails, check whether the failure is in the test logic or the app.

---

## Step 6: Audit Mode

When auditing an existing test suite, scan all `*.spec.ts` files and classify each `test()` as:

- **Journey-centric** — tests a full user goal end-to-end
- **Partial journey** — starts mid-flow or ends early
- **Feature-centric** — tests a page or component in isolation
- **Duplicate** — same journey covered elsewhere
- **Orphaned** — tests a flow that no longer exists

Report format:

```
Audit Report
============
Total tests: 34
Journey-centric:  6 (18%)
Partial journey:  8 (24%)
Feature-centric: 16 (47%)
Duplicate:        2 (6%)
Orphaned:         2 (6%)

Gaps (no E2E coverage):
- Password reset
- Admin user management

Recommended actions:
1. Restructure 16 feature-centric tests into journey-centric E2E tests
2. Delete 2 orphaned tests: [list them]
3. Add 2 missing journeys: [list them]
```

Present the audit and ask which actions to tackle before making any changes.
