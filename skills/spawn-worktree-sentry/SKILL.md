---
name: spawn-worktree-sentry
description: Spawn a new git worktree in a detached tmux session to investigate or fix a Sentry issue. Fetches the issue via the Sentry MCP, composes an initial prompt with the error context (stack trace, breadcrumbs, frequency), and seeds an opencode agent inside the new worktree. Use when the user wants to fork off work on a specific Sentry issue.
---

## Overview

A variant of [[spawn-worktree]] for Sentry issues. User supplies a Sentry issue ID or URL; this skill fetches it, composes a seed prompt, and spawns the worktree as `SENTRY-<short-id>/<slug>`. See [[spawn-worktree]] for the underlying mechanics — only the differences are documented here.

## When to use

User asks to spawn/fork a worktree starting from a Sentry issue (short ID, numeric ID, or full `sentry.io/issues/...` URL). For Linear tickets use [[spawn-worktree-linear]]; for freeform tasks use [[spawn-worktree]].

## Workflow

### 1. Fetch the issue

Extract the issue ID from a URL if needed. Use the available `mcp__sentry__*` tools to load:

- Title / error message, culprit (file:line, function)
- Stack trace (in-app frames, most recent first)
- Frequency: events, users, first/last seen
- Environment(s), release(s) affected
- A representative event with breadcrumbs and tags
- Any linked Linear/GitHub references

If not found, surface the error and stop.

### 2. Derive the slug

Branch segment: `SENTRY-<short-id>` lowercased with project prefix kept (e.g. `SENTRY-frontend-abc1`). If only a numeric ID is available, use `SENTRY-<num>`.

Task slug: error type + a few words of context (e.g. `TypeError: cannot read property 'id' of null in exportHandler` → `typeerror-id-of-null-export-handler`). Lowercase, dashes-only, strip non-`[a-z0-9-]`, collapse `-`, ~40 chars max.

Full name for `wt new`: `SENTRY-<short-id>/<slug>`.

### 3. Compose the seed prompt

Markdown, real newlines. Include enough context that the spawned agent doesn't need to re-query Sentry:

- `# Sentry <short-id>: <error title>`
- **Where:** culprit, environment, release
- **Frequency:** events, users, first/last seen
- **Stack trace:** in-app frames, most recent first; trim third-party unless load-bearing
- **Breadcrumbs:** last ~10 from a representative event
- **Tags:** anything that narrows the cause (browser, OS, user role, flag)
- **Linked tickets:** any Linear/GitHub refs
- **First steps:** reproduce locally / write a failing test; trace from culprit to root cause; confirm hypothesis with the user before patching
- Any extra user-provided guidance, appended

### 4. Confirm, spawn, report

Show the full `wt new` name, base branch, and seed prompt; ask the user to confirm or edit. Then spawn and report back per [[spawn-worktree]] steps 3–4. Always pass `--detach`.

## Important

- Do **not** resolve / ignore / mutate the Sentry issue.
- If the issue looks like noise (one event, no users, third-party error), say so before spawning — a worktree is overkill for triage.
- Everything else (existing-worktree handling, no-commit policy, etc.) — see [[spawn-worktree]].

$ARGUMENTS
