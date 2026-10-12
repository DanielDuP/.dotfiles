---
name: publish-draft-pr-review
description: Publish staged review-comments files as a verified pending GitHub pull request review without submitting it
---

## Overview

Publish inline comments from `review-comments/` as one GitHub pull request review in the `PENDING` state. Use this skill only when the user explicitly asks to publish or create a draft review. Creating the pending review is the only authorized mutation.

The highest-priority invariant is that the review remains `PENDING`. Never submit, approve, request changes, or create a submitted comment review as part of this skill.

## Input format

Read comments from `review-comments/` at the repository root. Each Markdown file represents one inline comment:

```text
review-comments/<source-path>:<line>.md
review-comments/<source-path>:<start-line>-<end-line>.md
```

For example:

```text
review-comments/members/views/events/hl7/boston_heart.py:43-44.md
```

The file body is the complete comment text. It must not contain frontmatter or metadata. Parse the location from the final `:<line-or-range>.md` suffix so nested source directories remain part of the GitHub path.

## Workflow

### 1. Resolve the pull request

1. Confirm that the current directory belongs to a Git repository and locate its root.
2. Resolve the current branch's open pull request. If no PR exists, or more than one PR could match, stop and ask the user for the PR URL or number.
3. Resolve the canonical `owner/repo`, PR number, PR URL, base SHA, and current head SHA through `gh`.
4. Resolve the authenticated GitHub login with `gh api user`.
5. Require local `HEAD` to equal the PR head SHA. If they differ, stop because the staged line locations may describe another revision.

Do not infer repository or PR identifiers from directory names when `gh` can provide them.

### 2. Load and validate staged comments

1. Recursively list regular `*.md` files under `review-comments/`.
2. Stop if the directory is missing, contains no comment files, or contains unsupported files.
3. Parse each filename using this suffix shape: `:<line>.md` or `:<start>-<end>.md`.
4. Reject absolute paths, path traversal, zero or negative lines, reversed ranges, duplicate locations, empty bodies, and malformed filenames.
5. Treat a range's final line as `line` and its first line as `start_line` in the GitHub payload.

Do not generate new comments or materially rewrite their content. The staged files are the review source of truth.

### 3. Validate the exact PR diff

Fetch the diff for the resolved PR and exact head SHA. For every staged location, verify all of the following:

- The path matches the right-side path in the PR diff. For a rename, use the new path.
- The target line is present on the `RIGHT` side of a diff hunk at the current head SHA.
- Every line in a range is present on the `RIGHT` side of the same hunk.
- The target is still commentable and has not become outdated.

Parse hunk headers and line movement rather than treating a displayed patch position as a source line. Context and added lines advance the right-side line number; deleted lines do not. If the API omits or truncates a patch, use the complete PR diff. If any location cannot be verified exactly, abort before creating a review.

### 4. Check for an existing pending review

List all reviews for the PR and filter by both the authenticated login and state `PENDING`. If a pending review already exists, abort and report its ID and link.

Do not add comments to an existing pending review. That requires a separately verified workflow. If this check is inconclusive, abort rather than risk creating or submitting the wrong review.

### 5. Build the review payload

Build JSON with `jq` so paths and bodies are escaped safely. Use the current PR head SHA as `commit_id` and include every comment in one `comments` array.

Before adding a body to the payload:

1. Replace every run of carriage returns and newlines with one space.
2. Trim leading and trailing whitespace.
3. Reject the comment if the resulting body is empty or still contains a newline.

Use this shape for one line:

```json
{
  "path": "src/example.py",
  "line": 42,
  "side": "RIGHT",
  "body": "Could we validate this value first? Otherwise malformed input reaches the database and fails after partial processing."
}
```

For a range, also include `start_line` and `start_side`:

```json
{
  "path": "src/example.py",
  "start_line": 40,
  "start_side": "RIGHT",
  "line": 42,
  "side": "RIGHT",
  "body": "Could we keep this update atomic? A failure between these writes leaves the records inconsistent."
}
```

The top-level payload must contain exactly `commit_id` and `comments`. Inspect the finished JSON before upload and reject any other top-level key.

**Omit the `event` field entirely.** Do not set it to `COMMENT`, `APPROVE`, `REQUEST_CHANGES`, an empty string, or `null`.

### 6. Create one pending review

Create the review with one REST request:

```bash
gh api --method POST "repos/<owner>/<repo>/pulls/<pr-number>/reviews" --input <payload-file>
```

Do not use `gh pr review`. Do not call `POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews/{review_id}/events`; that endpoint submits the review.

If the request fails or its result is ambiguous, do not retry immediately. Re-list the authenticated user's reviews first to determine whether GitHub created a pending review.

### 7. Verify the result

Immediately fetch the created review by ID and require its state to equal `PENDING`. Then list that review's comments and verify:

- The review commit ID equals the head SHA used in the request.
- The number of comments equals the number of staged files.
- Every expected path, line, range, and `RIGHT` side matches the created comments.
- Every uploaded body matches its normalized source and contains no carriage return or newline.

If any verification fails, report the partial failure and stop. Do not delete, recreate, submit, or otherwise modify the review automatically.

After successful verification, report the PR URL, review link, review ID, state, and comment count. State explicitly that the review is pending and has not been submitted.

## Safety

- Treat "publish as draft" as permission to create one `PENDING` review only.
- Never submit the review unless the user makes a separate, explicit request after inspecting the draft.
- Never call a review submission endpoint during this skill, even for verification.
- Never use a non-head commit or an unverified diff location.
- Never publish only a subset after validation fails; the review must be created with one comments array.
- Never delete or modify the local `review-comments/` files.
