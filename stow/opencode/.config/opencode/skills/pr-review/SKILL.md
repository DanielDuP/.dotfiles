---
name: pr-review
description: Exhaustive file-by-file PR review with written per-file and holistic review artifacts
---

## Overview

Perform a thorough, structured code review of the current branch's PR. Produce written review artifacts: one markdown file per changed file, plus a holistic summary. All review files are written into the repository being reviewed (i.e. the repo root).

## Workflow

### 1. Determine the PR name and base branch

- Run `git branch --show-current` to get the current branch name.
- Derive the **PR name** from the branch name (e.g. `feature/add-auth` becomes `add-auth`, `fix/login-bug` becomes `login-bug`). Strip common prefixes like `feature/`, `fix/`, `chore/`, `refactor/`, etc. If the branch name has no prefix, use it as-is.
- Identify the base branch this was forked from. Typically `main` or `master`. You can check with `git merge-base --fork-point main HEAD` or similar. If unclear, ask.

### 2. Gather context

- Run `git log <base>..HEAD --oneline` to see the full commit history for this branch.
- Run `git diff <base>..HEAD --stat` to get an overview of all changed files and the scope of changes.
- Read relevant documentation, READMEs, or surrounding code to understand the feature area being modified. Aim to understand the *intent* of the PR before judging the implementation.

### 3. File-by-file review

- Get the list of changed files: `git diff <base>..HEAD --name-only`.
- For **each** changed file:
  1. Read the full diff for that file: `git diff <base>..HEAD -- <filepath>`.
  2. Read the current version of the file for full context (not just the diff).
  3. Conduct an exhaustive review covering:
     - **Correctness** — Does the logic do what it intends? Are there edge cases or bugs?
     - **Design** — Does this fit well within the existing architecture? Are abstractions appropriate?
     - **Readability** — Is the code clear? Are names descriptive? Is it well-structured?
     - **Performance** — Are there unnecessary allocations, O(n^2) loops, or missed optimizations?
     - **Security** — Any injection risks, leaked secrets, or unsafe operations?
     - **Testing** — Are changes tested? Are there obvious missing test cases?
     - **Error handling** — Are errors handled gracefully? Are failure modes considered?
  4. Note any cross-file considerations (e.g. "this change assumes X in `other-file.ts`").
   5. **Write the review** to `reviews/<pr-name>/file/<filename>.md` at the repo root (the repository being reviewed), where `<filename>` mirrors the source path with `/` replaced by `__` (e.g. `src/utils/auth.ts` becomes `src__utils__auth.ts.md`).

Each per-file review should include:
- The file path and a short summary of what changed
- Specific findings with line references where applicable
- Severity indicators: `[critical]`, `[warning]`, `[suggestion]`, `[nit]`
- Cross-file considerations if relevant

### 4. Holistic review

After all files are reviewed, write `reviews/<pr-name>/review.md` at the repo root containing:

- **Summary** — What does this PR do? One paragraph.
- **Scope** — List of files changed with one-line descriptions.
- **Key findings** — The most important issues across all files, ranked by severity.
- **Cross-cutting concerns** — Patterns that span multiple files (e.g. inconsistent error handling, missing validation at boundaries).
- **Architecture considerations** — Does this PR move the codebase in a good direction?
- **Testing assessment** — Is test coverage adequate for the changes?
- **Verdict** — Overall assessment: approve, request changes, or needs discussion. Be direct.

## Guidelines

- Be thorough but not pedantic. Focus energy on things that matter.
- Distinguish between blocking issues and nice-to-haves.
- If something looks wrong but you are not sure, say so — flag it as a question rather than a defect.
- Give credit where due. If something is well-done, note it briefly.
- All review files are markdown (`.md`).
