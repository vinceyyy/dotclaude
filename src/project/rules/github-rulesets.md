# GitHub Repository Rulesets

Standard branch protection rulesets for projects using the `main` + `dev` branching model.

## Branch Model

- `main` — production, always stable
- `dev` — integration branch, deploys to staging
- `feat/*`, `fix/*`, `refactor/*` — short-lived feature branches targeting `dev`

## Ruleset: Protect dev

**Target:** `refs/heads/dev`
**Enforcement:** Active, no bypass actors

| Rule | Setting |
|------|---------|
| Prevent deletion | Yes |
| Prevent non-fast-forward (force push) | Yes |
| Require pull request | Yes, 0 approvals required |
| Allowed merge methods | Squash only |
| Require linear history | Yes |
| Require status checks to pass | Yes, strict (branch must be up to date) |
| Enforce on branch creation | No |

**Required status checks** (adjust per project):
- Lint (TypeScript)
- Lint (Python) per service
- Lint (Plugin) if applicable
- Test (Console)
- Test (Python) per service

**Why these choices:**
- **Squash only** — each feature becomes one clean commit on `dev`, keeping history readable
- **Linear history** — ensures every commit on `dev` was tested against the current state, not a stale base
- **Strict status checks** — PR must be rebased onto latest `dev` before merge, preventing untested combinations
- **0 approvals** — for small teams or solo projects; increase for larger teams

## Ruleset: Protect main

**Target:** `refs/heads/main`
**Enforcement:** Active, no bypass actors

| Rule | Setting |
|------|---------|
| Prevent deletion | Yes |
| Prevent non-fast-forward (force push) | Yes |
| Require pull request | Yes, 0 approvals required |
| Allowed merge methods | Merge (regular) only |

**Why these choices:**
- **Regular merge only** — preserves the full `dev` history when promoting to production; `dev → main` merges are
  infrequent and represent release boundaries
- **No status checks** — CI already ran on `dev`; `main` merges are promotions, not new code
- **No linear history** — merge commits from `dev → main` are intentional release markers

## Setting Up on a New Repo

```bash
# View existing rulesets
gh api repos/OWNER/REPO/rulesets

# The rulesets are configured via GitHub UI:
# Repo → Settings → Rules → Rulesets → New ruleset
```

## CI/CD Concurrency (companion pattern)

Pair these rulesets with two-tier CI/CD concurrency in GitHub Actions:

```yaml
# Workflow level — cancel stale test jobs
concurrency:
  group: deploy-stg-tests
  cancel-in-progress: true

jobs:
  # Test jobs here...

  deploy:
    needs: [tests...]
    # Job level — never cancel infra deploys (CloudFormation/SST)
    concurrency:
      group: deploy-stg-infra
      cancel-in-progress: false
```

This avoids wasting CI minutes on superseded commits while protecting infrastructure deploys from
being cancelled mid-update.
