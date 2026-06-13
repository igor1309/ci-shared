# ci-shared

Shared GitHub Actions workflows and scripts for reuse across repositories.

This repository is intended to be **consumed**, not copied.

---

## What this repo provides

- **Reusable workflows** (`.github/workflows/*`)  
  Standardized CI workflows that can be invoked from other repositories via `workflow_call`.

- **Shared scripts** (`.github/scripts/*`)  
  Implementation logic used by reusable workflows.  
  Scripts are checked out and executed by the workflows — client repos do **not** contain copies.

- **Shared local scripts** (`scripts/*`)  
  Scripts intended to be vendored into client repositories at a pinned commit SHA.

---

## Usage (client repositories)

Example workflow in a client repo:

```yml
name: Sandbox & TODO Issue Auto-Creation

on:
  push:
    branches: [trunk]

jobs:
  create-issues:
    uses: igor1309/ci-shared/.github/workflows/sandbox-todo-issues.yml@main
    permissions:
      issues: write
      contents: read
```

Notes:
- No scripts are required in the client repository.
- Permissions are defined by the caller.
- Pin the workflow ref to match your stability needs (e.g., a commit SHA or `main`).
- Shared scripts are intentionally checked out from the default branch (non-pinned), even when the workflow ref is pinned.

For local development scripts in `scripts/*`, use pinned vendoring:
- Copy the script into the client repo under `vendor/ci-shared/...`.
- Record source repo/path and commit SHA in the vendored file header.
- Keep a stable local wrapper entrypoint (for example `./scripts/run_silent.sh`) that delegates to the vendored file.

---

## Behavior notes

- Issues are created for newly added `sandbox/` top-level entries, `TODO.md` files, and backlog items (`backlog.md`, or any `.md` added inside a `backlog/` folder).
- Renames are treated as additions and may trigger new issues.
- Script changes on the default branch take effect immediately for all callers.

---

## Design principles

- **Single source of truth** for CI logic
- **No script duplication** across client repositories
- **Clear references** over implicit “latest”
- **Minimal surface area** exposed to consumers

---

## Non-goals

- Providing binaries or artifacts
- Per-repository customization via copied files

---

## License

MIT
