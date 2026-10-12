---
name: commit-pr
description: Generate a commit message prefixed with a Linear ticket ID, create the commit, and optionally open a PR
---

## Overview

Given a Linear ticket ID, review the current changes, generate a commit message that doubles as a PR description, create the commit, and optionally push and open a PR.

## Workflow

### 1. Resolve the ticket ID

The user should provide a Linear ticket ID (e.g. `ENG-1234`). If none is given, ask for one and stop.

### 2. Gather context

Run in parallel:

- `git branch --show-current`
- `git status --short`
- `git diff --cached --stat`
- `git diff --stat`

Review both staged and unstaged changes to understand what's being committed.

### 3. Generate the commit message

Produce a message that:

- Starts with `<TICKET-ID>:` (the provided Linear ticket ID)
- Has a concise, descriptive title on the first line
- Includes a detailed description of changes
- Can serve as both the commit message and PR description
- Follows conventional commit conventions when applicable

Format:

```
<TICKET-ID>: Brief description of changes

## Summary
- Bullet points describing what was changed
- Why the changes were made
- Any important implementation details

## Test Plan
- How to test the changes
- What to verify
```

### 4. Workflow

1. Show the generated message to the user.
2. Ask whether to stage all changes (if anything is unstaged).
3. Create the commit with the generated message.
4. Ask whether to push the branch to remote.
5. If pushed, offer to create a PR: `gh pr create --title "<TICKET-ID>: Title" --body "<full message>"`.

## Guidelines

- Pass commit messages and PR bodies via a heredoc to preserve formatting.
- Never amend an existing commit unless the user explicitly asks.
- Never `--no-verify` or skip hooks.
- Stage specific files rather than `git add -A` to avoid accidentally including secrets or large binaries.
- Do not push or open a PR without user confirmation.
