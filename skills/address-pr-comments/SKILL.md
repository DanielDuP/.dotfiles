---
name: address-pr-comments
description: Fetch and address non-outdated PR review comments on the current branch
---

## Overview

Fetch all non-outdated review comments on the current branch's PR, categorize them, and address the actionable ones with code changes.

## Workflow

### 1. Identify the PR

- Get the current branch: `git branch --show-current`
- Find the open PR for this branch:

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,url --jq '.[0]'
```

If no PR is found, stop and inform the user.

### 2. Fetch non-outdated comments

Use the GitHub GraphQL API to fetch only comments that are **not outdated** (still relevant to the current code):

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviews(last: 100) {
        nodes {
          author { login }
          comments(last: 100) {
            nodes {
              body
              outdated
              path
              line: originalStartLine
              endLine: originalLine
              author { login }
            }
          }
        }
      }
    }
  }
}' -F owner='{owner}' -F repo='{repo}' -F pr={number} \
  --jq '.. | .nodes? // empty | .[] | select(.outdated? == false) | select(.body? != null)'
```

Replace `{owner}`, `{repo}`, and `{number}` with the values from step 1.

### 3. Categorize comments

For each non-outdated comment, categorize it as one of:

- **Actionable** — nits, change requests, bug reports (has a concrete code change to make)
- **Discussion** — questions, observations, design thoughts (no code change needed, but worth surfacing)
- **Positive** — compliments, approvals (no action needed)

### 4. Present summary to user

Show a summary grouped by category:

**Actionable** — list each with file path + line, reviewer, comment text, and a brief description of what change is needed.

**Discussion** — list so the user can decide how to respond.

**Positive** — briefly mention (no action needed).

### 5. Address actionable comments

For each actionable comment:

1. Read the relevant file and lines
2. Make the requested code change
3. Move on to the next comment

## Guidelines

- Do **not** create a commit. The user will handle committing.
- Do **not** reply to comments on GitHub.
- If a comment is ambiguous or requires a design decision, flag it to the user instead of guessing.
