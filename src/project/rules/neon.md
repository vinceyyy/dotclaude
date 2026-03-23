# Neon Rules

## Database Branching

Each git branch **MUST** use its own Neon database branch. Never run schema changes, tests, or local dev against the
`main` Neon branch from a feature branch.

### Create a branch

When starting work on a feature branch:

1. `mcp__Neon__create_branch` — parent: `main` (or `dev`), name: matches git branch
2. `mcp__Neon__get_connection_string` — get the branch connection string
3. Update `DATABASE_URL` in `.env` to the branch connection string
4. Push schema to the new branch (e.g., `db:push`, `prisma migrate deploy`)

### Clean up

Delete the Neon branch after the git branch is merged or abandoned. Use `mcp__Neon__delete_branch`.
Do not delete the `main` Neon branch.

Leaked branches accumulate and cost money — always clean up.
