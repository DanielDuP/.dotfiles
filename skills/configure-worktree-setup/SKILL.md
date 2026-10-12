---
name: configure-worktree-setup
description: Configure a trusted local .git/wt-setup script for automatic worktree dependency installation and environment setup. Use when the user asks to define, create, or update worktree setup for a repository.
---

## Overview

Create or update the current repository's `.git/wt-setup` executable. `wt new` runs this local hook from a newly created worktree before starting tmux or opencode.

The hook is deliberately stored under the shared Git directory. It cannot be committed, cloned, or changed by switching branches. Never create a tracked `.worktree-setup` alternative.

## Workflow

### 1. Inspect the project

Identify the repository root, package manifests, lockfiles, example environment files, and any documented bootstrap commands. Read existing setup documentation and package-manager scripts before choosing commands.

Resolve the hook path from the main checkout:

```bash
repo_root="$(git rev-parse --show-toplevel)"
git_common_dir="$(git rev-parse --git-common-dir)"
[[ "$git_common_dir" = /* ]] || git_common_dir="$repo_root/$git_common_dir"
hook="$git_common_dir/wt-setup"
```

If the hook already exists, read it and preserve behavior the user did not ask to change. Ask before replacing it wholesale.

### 2. Design an idempotent hook

Use this baseline:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Project-specific setup goes here.
```

The hook runs with:

- Its working directory set to the new worktree root.
- `WT_WORKTREE` set to the new worktree path.
- `WT_MAIN_WORKTREE` set to the main checkout path.

Follow these safety rules:

- Make repeated runs safe. A dead tmux session causes setup to run again when `wt new` recreates it.
- Never overwrite an existing environment file. Guard copies with `[[ -e .env ]]` or `cp -n`.
- Prefer copying an existing ignored environment file from `$WT_MAIN_WORKTREE`; otherwise copy the repository's example file.
- Quote all paths and variables.
- Use the package manager selected by the lockfile and its frozen or reproducible install mode where available.
- Check `package.json` scripts before invoking project tools through `npx`, `pnpm dlx`, or `yarn dlx`.
- Do not embed credentials or secret values in the hook itself.
- Keep the setup project-specific rather than adding speculative detection for unrelated ecosystems.

For example:

```bash
if [[ ! -e .env ]]; then
  if [[ -f "$WT_MAIN_WORKTREE/.env" ]]; then
    cp "$WT_MAIN_WORKTREE/.env" .env
  elif [[ -f .env.example ]]; then
    cp .env.example .env
  fi
fi

pnpm install --frozen-lockfile
```

### 3. Confirm risky behavior

Before writing the hook, show the proposed script and call out:

- Dependency installers may execute lifecycle scripts from the checked-out branch.
- Environment files copied into a worktree become accessible to code and agents running there.
- This mechanism is intended for trusted development branches. `rv new` does not run it for review worktrees.

Ask the user to confirm when the script installs dependencies, copies secrets, starts services, or performs another consequential action.

### 4. Write and enable it

Write the approved script to the resolved `wt-setup` path and make it executable:

```bash
chmod +x "$hook"
```

Do not add the hook to `.gitignore`; files beneath `.git` are already outside the worktree and cannot be tracked.

### 5. Verify

Run a shell syntax check using the interpreter from the shebang. Do not execute the full setup merely to test it unless the user explicitly approves that action.

Report the hook path, summarize its actions, and remind the user that it will run on the next `wt new` before the tmux session starts.

## Failure behavior

If setup exits nonzero, `wt new` leaves the new worktree in place but does not create its tmux session. After correcting the hook or its inputs, rerun the same `wt new` command to retry.

$ARGUMENTS
