---
name: spawn-worktree
description: Spawn a new git worktree in a detached tmux session and seed an opencode agent inside it with an initial prompt. Use when the user wants to fork off parallel work without leaving the current session.
---

## Overview

Creates a fresh git worktree + tmux session via the `wt` shell function, launches `opencode` in the agent window pre-seeded with an initial prompt, and leaves the new session detached so the current session keeps focus. The user can switch over with `prefix+w` when ready.

## When to use

- The user asks to "fork", "spawn", "kick off", or "start a parallel" task.
- The user describes a self-contained piece of work they want handled in the background while continuing here.
- The user explicitly invokes this skill.

Do **not** use it for work that belongs in the current branch/session.

## Inputs

The user should provide:

- A **task name** (short, used as the worktree directory and branch slug).
- An **initial prompt** — what the spawned opencode agent should start working on.
- Optionally a **base branch** (defaults to `HEAD`).

If either the name or the prompt is missing, ask for it before proceeding. Don't invent a task name from thin air — confirm it.

## Workflow

### 1. Sanitize the task name

Convert the task name to a branch-safe slug:

- Lowercase
- Spaces and underscores → `-`
- Strip characters outside `[a-z0-9._/-]`
- Collapse repeated `-`

Do **not** add a `username/` prefix — `wt new` handles that automatically.

### 1a. Ticket-segment convention

If the work is associated with a specific tracked issue, include its ID as a segment between the user prefix and the task slug by passing `<TICKET-ID>/<slug>` as the name. Format conventions:

- **Linear**: raw ID, e.g. `ENG-1234/fix-rate-limit`
- **Sentry**: `SENTRY-<short-id>`, e.g. `SENTRY-abc123/null-deref-in-export`
- **GitHub issue**: `gh-<num>`, e.g. `gh-482/parser-crash`

Use the dedicated `spawn-worktree-linear` or `spawn-worktree-sentry` skill instead when the user starts from a ticket ID — those variants auto-fetch context to seed the prompt. Use this convention here only when the user mentions a ticket in passing while spawning a manually-described task.

If you're unsure whether a mentioned ID is actually the subject of the work (vs. just referenced), ask the user.

### 2. Confirm with the user

Show the user:

- The sanitized slug
- The base branch
- The full initial prompt (verbatim — this is what opencode will receive)

Ask them to confirm before spawning. This is cheap and prevents launching an agent down the wrong path.

### 3. Spawn the worktree

Run, from anywhere inside the current repo:

```bash
zsh -c 'source ~/.config/zsh/functions/wt.zsh && wt new <slug> --detach --prompt "<prompt>"'
```

Notes:

- `--detach` is **required** — without it `wt new` will switch the current tmux client to the new session and yank focus away from this conversation.
- Pass the prompt as a single shell-quoted argument. Prefer single quotes around the prompt; if the prompt itself contains single quotes, switch to double quotes and escape `"`, `\`, `$`, and backticks.
- If `--branch <base>` was requested, add it before `--prompt`.

### 4. Report back

After `wt new` exits, tell the user:

- The session name it created (output line: `wt: session 'wt/<repo>/<user>/<slug>' ready (detached)`)
- The worktree path
- That they can jump in with `prefix+w` (the worktree picker)

Then return control — do **not** try to interact with the spawned agent from here.

## Important

- This skill does not commit, push, or open PRs. The spawned agent handles its own work; cleanup happens via `wt rm <name>`.
- `wt new` reuses existing worktrees / recreates dead sessions transparently — don't pre-check or guard against that.
- Never drop `--detach`. If the user explicitly wants to switch into the new session, they can do so manually after spawn.

$ARGUMENTS
