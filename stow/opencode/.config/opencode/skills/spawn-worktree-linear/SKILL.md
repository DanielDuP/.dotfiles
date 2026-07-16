---
name: spawn-worktree-linear
description: Spawn a new git worktree in a detached tmux session for a Linear ticket. Fetches the ticket via the Linear MCP, composes an initial prompt with the ticket context, and seeds an opencode agent inside the new worktree. Use when the user wants to fork off work on a specific Linear ticket.
---

## Overview

A variant of [[spawn-worktree]] for Linear tickets. User supplies a ticket ID; this skill fetches it, composes a seed prompt, and spawns the worktree as `<TICKET-ID>/<slug>`. See [[spawn-worktree]] for the underlying mechanics — only the differences are documented here.

## When to use

User asks to spawn/fork a worktree starting from a Linear ticket ID (e.g. `ENG-1234`). For freeform tasks, use [[spawn-worktree]].

## Workflow

### 1. Fetch the ticket

Normalize the ID (uppercase prefix, e.g. `eng-1234` → `ENG-1234`). Call `mcp__linear__get_issue` and `mcp__linear__list_comments` — AC and design decisions often live in comments. If not found, surface the error and stop.

### 2. Derive the slug

From the ticket title: lowercase, spaces/underscores → `-`, strip non-`[a-z0-9._-]`, collapse `-`, truncate to ~40 chars at a word boundary.

Full name for `wt new`: `<TICKET-ID>/<slug>` (e.g. `ENG-1234/fix-rate-limit-on-export`).

### 3. Compose the seed prompt

Markdown, real newlines:

- `# <TICKET-ID>: <title>`
- **Goal:** one-sentence restatement
- **Description:** ticket body verbatim (trim if huge)
- **Acceptance criteria:** bulleted, from description + comments
- **Notable comments:** anything with design decisions / blockers / AC not in description
- **Metadata:** status, labels, priority, parent/project — one line
- **First steps:** confirm scope, produce a plan before editing (mirroring [[implement-ticket]])
- Any extra user-provided guidance, appended

### 4. Confirm, spawn, report

Show the full `wt new` name, base branch, and seed prompt; ask the user to confirm or edit. Then spawn and report back per [[spawn-worktree]] steps 3–4. Always pass `--detach`.

## Important

- Do **not** change the Linear ticket's status or assignee.
- If the ticket is large/vague, suggest splitting before spawning.
- Everything else (existing-worktree handling, no-commit policy, etc.) — see [[spawn-worktree]].

$ARGUMENTS
