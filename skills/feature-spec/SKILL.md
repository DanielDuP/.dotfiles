---
name: feature-spec
description: Spec out a feature through context gathering, user interview, and written spec documents
---

## Overview

Design a feature by first understanding the codebase, then interviewing the user to clarify requirements, and finally producing terse spec documents in a `specs/<feature-name>/` folder at the repo root.

## Workflow

### 1. Gather context

Before asking the user anything, silently build understanding of the codebase:

- Read the top-level directory structure and key config/manifest files.
- Identify the tech stack, frameworks, database, and major architectural patterns.
- Read existing specs, architecture docs, or READMEs if they exist.
- Look at the areas of the codebase most likely to be touched by the feature (based on whatever the user has told you so far).
- Examine existing data models, API routes, and service boundaries to understand what already exists.

Present a brief summary of what you found that is relevant to the feature. This grounds the conversation and lets the user correct any misunderstandings early.

### 2. Interview the user

Ask focused questions to fill in gaps. Do this in rounds — do not dump 20 questions at once.

Each round should have 2-5 questions max. Prioritize:

- **What** — What exactly should this feature do? What is the user-facing behavior?
- **Why** — What problem does this solve? What is the motivation?
- **Scope** — What is explicitly out of scope? What is the MVP vs. future work?
- **Constraints** — Are there performance requirements, compatibility concerns, or deadlines?
- **Integration** — How does this interact with existing features, data, and services?
- **Edge cases** — What happens when things go wrong? What are the boundary conditions?

Stop interviewing when you have enough clarity to write the spec. Do not over-interview — if the user gives a clear, complete answer, move on. Typically 1-3 rounds is sufficient.

### 3. Write the spec

Create a `specs/<feature-name>/` directory at the repo root. The feature name should be a short kebab-case slug derived from the feature description.

Only produce the documents that are relevant to the feature. Pick from the following — do not include docs that add no value:

#### `overview.md` (always included)
- One-paragraph summary of the feature.
- Goals and non-goals (bullet points).
- User stories or key use cases (brief).

#### `architecture.md` (if the feature involves new components, services, or significant structural changes)
- How the feature fits into the existing system.
- New components/modules introduced and their responsibilities.
- Data flow diagram (ASCII or brief prose).
- Key technical decisions and rationale.

#### `data-models.md` (if the feature involves new or modified database models/schemas)
- New tables/collections/types with fields, types, and constraints.
- Modifications to existing models.
- Indexes and relationships.
- Use concise table format or pseudocode — not full migration SQL.

#### `api.md` (if the feature exposes or modifies API endpoints)
- Endpoints: method, path, request/response shapes.
- Authentication/authorization requirements.
- Error responses.
- Use compact format — no verbose OpenAPI, just the essentials.

#### `ui.md` (if the feature has meaningful UI/UX considerations)
- Key screens or components.
- User flow (step by step).
- State management considerations.
- No mockups — just describe what the user sees and does.

#### `tasks.md` (always included)
- Ordered implementation plan broken into concrete, small tasks.
- Each task should be independently deliverable where possible.
- Note dependencies between tasks.
- Flag anything that needs further investigation.

## Document style

- **Terse.** Every sentence should earn its place. No filler, no preamble, no "In order to facilitate...".
- **Concrete.** Use real names from the codebase. Reference actual files, modules, types, and endpoints.
- **Flat.** Prefer bullet points and tables over prose. Minimal nesting.
- **Opinionated.** Make decisions, don't present menus of options. If a choice is genuinely open, say so briefly and flag it for the user.

## Guidelines

- Do not write code. This skill produces specs only.
- If the feature is simple, the spec may be just `overview.md` and `tasks.md`. Do not over-document.
- If a `specs/` directory already exists with other features, that is fine — each feature gets its own subdirectory.
- Ground everything in the actual codebase. A spec that ignores existing patterns is useless.
- If you discover something during context gathering that changes the feasibility or approach, surface it immediately during the interview rather than burying it in the spec.
