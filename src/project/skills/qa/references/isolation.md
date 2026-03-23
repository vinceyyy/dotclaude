# Data Isolation Protocol

Both `e2e` and `qa-journey` modes must run against isolated state. This prevents:
- Tests polluting each other
- QA runs dirtying the dev database
- Parallel runs interfering with each other

---

## The Protocol (adapter-independent)

Every run follows this lifecycle:

```
1. CREATE   → spin up isolated DB/state
2. MIGRATE  → apply schema to isolated state
3. SEED     → insert baseline test data
4. RUN      → execute tests/QA against isolated state
5. TEARDOWN → always runs, even on failure
```

The implementation of steps 1, 2, 3, and 5 depends on what DB/infrastructure the repo uses.
Step 4 is always the same: point the app at the isolated state URL.

---

## Detecting What the Repo Uses

Check in order:
1. Is there a `.env` or `.env.example` with `DATABASE_URL`?
2. Does the URL contain `neon.tech`? → Use Neon adapter (see below)
3. Does `docker-compose.yml` exist with a `postgres` or `mysql` service? → Use Docker adapter
4. Is there a `DATABASE_URL` pointing to `localhost`? → Ask the user how isolation should work

If you can't determine the isolation approach, ask the user before proceeding:
> "How should I isolate the database for this test run? I can create a Neon branch, spin up a Docker container, or use another approach."

---

## Neon Adapter (Reference Implementation)

Neon's branching is ideal for isolation: each branch is a full copy-on-write clone of the parent, created in seconds.

### Create

```
mcp__Neon__list_projects           → find the project ID
mcp__Neon__create_branch           → name: "e2e-{timestamp}", parent: "dev" or "main"
mcp__Neon__get_connection_string   → save as ISOLATED_DATABASE_URL
```

Save the branch ID — you'll need it for teardown.

### Migrate

Check what migration tool the project uses (`drizzle-kit`, `prisma`, `knex`, `flyway`):

```bash
# Drizzle
DATABASE_URL="$ISOLATED_DATABASE_URL" npx drizzle-kit push

# Prisma
DATABASE_URL="$ISOLATED_DATABASE_URL" npx prisma migrate deploy

# Other: look for a migrate script in package.json
DATABASE_URL="$ISOLATED_DATABASE_URL" npm run db:migrate
```

### Seed

Look for a seed script in `package.json` or `scripts/`:

```bash
DATABASE_URL="$ISOLATED_DATABASE_URL" npm run seed
# or
DATABASE_URL="$ISOLATED_DATABASE_URL" npx tsx scripts/seed.ts
```

If no seed script exists, create minimal data via the API after the server starts (register a user, etc.).

### Point the app at isolated state

For `e2e` mode — set in `playwright.config.ts` or `.env.test`:
```bash
DATABASE_URL="$ISOLATED_DATABASE_URL" npx playwright test
```

For `qa-journey` mode — set when starting the dev server:
```bash
DATABASE_URL="$ISOLATED_DATABASE_URL" npm run dev
```

### Teardown

```
mcp__Neon__delete_branch  → branch ID saved from create step
```

**Always run this**, even if tests failed. Leaked branches accumulate and cost money.

Wrap in a try/finally pattern conceptually:
```
try:
  create → migrate → seed → run
finally:
  teardown
```

---

## Docker Adapter

If the repo uses Docker Compose with a database service:

### Create
```bash
# Start a fresh isolated container with a unique name
docker run -d \
  --name e2e-postgres-$(date +%s) \
  -e POSTGRES_DB=e2e_test \
  -e POSTGRES_USER=test \
  -e POSTGRES_PASSWORD=test \
  -p 0:5432 \
  postgres:15-alpine

# Get the assigned port
ISOLATED_PORT=$(docker port e2e-postgres-... 5432/tcp | cut -d: -f2)
ISOLATED_DATABASE_URL="postgresql://test:test@localhost:$ISOLATED_PORT/e2e_test"
```

### Teardown
```bash
docker stop e2e-postgres-{name}
docker rm e2e-postgres-{name}
```

---

## Minimal Isolation (No Branching Available)

If neither Neon nor Docker is available, use a unique schema or database name within an existing Postgres instance:

```bash
ISOLATED_SCHEMA="e2e_$(date +%s)"
psql $DATABASE_URL -c "CREATE SCHEMA $ISOLATED_SCHEMA"
# Run migrations targeting this schema
# After run:
psql $DATABASE_URL -c "DROP SCHEMA $ISOLATED_SCHEMA CASCADE"
```

This is less clean but acceptable for local development.

---

## What Good Seed Data Looks Like

Seed data should provide:
- At least one user per role type (guest-capable, authenticated, admin)
- Enough content that pages don't show empty states (unless testing empty states)
- Known, stable credentials that helpers/actions.ts can reference

```typescript
// Good seed: predictable, stable, just enough
const users = [
  { email: 'admin@test.dev', password: 'testpassword', role: 'admin' },
  { email: 'alice@test.dev', password: 'testpassword', role: 'user' },
];
const projects = [
  { name: 'Seed Project Alpha', ownerId: alice.id },
];
```

Don't over-seed. More data = slower setup and harder to reason about test state.
