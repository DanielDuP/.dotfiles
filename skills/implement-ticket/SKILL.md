---
name: implement-ticket
description: Start implementing a Linear ticket given its ID. Fetches ticket details, plans the work, and begins implementation in the current working tree.
---

## Overview

Take a Linear ticket ID (e.g. `ENG-1234`) and begin implementing it.

## Workflow

### 1. Resolve the ticket ID

The user should provide a ticket ID. If none is given, ask for one and stop.

Trim whitespace and uppercase the prefix (e.g. `eng-1234` → `ENG-1234`).

### 2. Fetch ticket details

Use the Linear MCP `get_issue` tool with the ticket ID to load:

- Title
- Description
- Status
- Assignee
- Labels
- Priority
- Linked project / parent issue

Also fetch comments via Linear MCP `list_comments` for additional context (acceptance criteria, design decisions, blockers often live there).

If the ticket cannot be found, stop and surface the error to the user.

### 3. Summarize and confirm scope

Present a concise summary to the user:

- **Ticket:** `<ID>` — `<title>`
- **Goal:** one-sentence restatement of what needs to be built
- **Acceptance criteria:** bulleted list extracted from description/comments
- **Open questions:** anything ambiguous that needs clarification before coding

Stop and ask the user to confirm scope (and answer any open questions) before proceeding. Do not skip this step — implementing the wrong thing wastes more time than a brief check-in.

### 4. Plan the implementation

Before editing code, produce a short plan:

- Which files/modules need to change
- New files to create
- Tests to add or update
- Any migrations, config, or infra changes

Use the codebase (Read/Grep/Glob) to ground the plan in real file paths. Surface the plan to the user briefly, then proceed.

### 5. Implement

Work through the plan, editing files and running tests/typechecks as you go. Follow the project's existing conventions and the user's global instructions (e.g. prefer `npm run <script>` over `npx`).

### 6. Hand-off

When the implementation is at a natural checkpoint:

- Summarize what changed and what's left (if anything)
- Do **not** commit or open a PR automatically — leave that to the user (or to the `commit-pr` skill)

## Guidelines

- Do not change the Linear ticket's status or assignee unless the user asks.
- If the ticket is very large or vague, propose splitting it and check with the user before writing code.
