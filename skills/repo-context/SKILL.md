---
name: repo-context
description: Gather comprehensive context on the current repository in preparation for working on it
---

## Overview

Perform a thorough exploration of the current repository to build a mental model of its structure, conventions, and key patterns. This prepares you to work on the codebase effectively without repeatedly asking clarifying questions or making incorrect assumptions.

## Workflow

### 1. Identify the project

- Run `git remote -v` to determine the repository origin.
- Run `git branch --show-current` to identify the active branch.
- Run `git log --oneline -10` to see recent activity.

### 2. Read top-level documentation

- Read `README.md` (or equivalent) if it exists.
- Read `CONTRIBUTING.md`, `ARCHITECTURE.md`, `DEVELOPMENT.md`, or any similar docs at the repo root.
- Read `CHANGELOG.md` or `HISTORY.md` if present — skim recent entries for context on what has been changing.

### 3. Understand project structure

- List the top-level directory structure.
- Identify the primary language(s) and framework(s) from file extensions, config files, and dependencies.
- Map out the high-level architecture:
  - Where does application/library source code live?
  - Where do tests live? What testing framework is used?
  - Where is configuration kept?
  - Are there build scripts, CI configs, or infrastructure definitions?
- If it is a monorepo, identify the packages/services and their relationships.

### 4. Inspect dependency and build configuration

- Read the relevant manifest files (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Gemfile`, `pom.xml`, etc.).
- Note key dependencies and their purposes.
- Identify build, test, lint, and format commands.
- Check for a lockfile to confirm dependency management approach.
- Look for tool configuration files (`.eslintrc`, `tsconfig.json`, `rustfmt.toml`, `.editorconfig`, `biome.json`, etc.) to understand code style and conventions.

### 5. Understand code patterns and conventions

- Sample a few representative source files to observe:
  - Naming conventions (files, functions, variables, types).
  - Module/import patterns.
  - Error handling approach.
  - Logging patterns.
  - How configuration and environment variables are accessed.
- Look at the test directory to understand testing patterns and conventions.
- Check for shared utilities, helpers, or internal libraries the codebase relies on.

### 6. Review CI/CD and development workflow

- Check for CI configuration (`.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`, etc.).
- Note what checks run on PRs (linting, tests, type checking, builds).
- Look for git hooks (`.husky/`, `.githooks/`, `lefthook.yml`, `.pre-commit-config.yaml`).
- Check for a `Makefile`, `Taskfile`, `justfile`, or similar task runner.

### 7. Produce a summary

Output a concise summary to the user covering:

- **Project** — What this repo is (one or two sentences).
- **Tech stack** — Languages, frameworks, key libraries.
- **Structure** — High-level directory layout and what lives where.
- **Development commands** — How to build, test, lint, and run the project.
- **Conventions** — Notable patterns, naming styles, or architectural decisions.
- **Current state** — Active branch, recent changes, anything in progress.
- **Gotchas** — Anything unusual, non-obvious, or important to keep in mind.

## Guidelines

- Be efficient. Use glob and grep over reading entire files when skimming is sufficient.
- Do not modify any files. This skill is read-only reconnaissance.
- If the repo is very large, focus depth on the areas most likely to be relevant and skim the rest.
- If you cannot determine something with confidence, say so rather than guessing.
- Keep the final summary concise and actionable — it should be a quick reference, not an essay.
