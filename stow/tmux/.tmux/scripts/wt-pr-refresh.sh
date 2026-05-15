#!/usr/bin/env zsh
# wt-pr-refresh — refresh cached PR status for a worktree session.
# Runs detached from `set-hook -g client-session-changed`. Errors silently.

set -uo pipefail

session="${1:-}"
[[ -z "$session" ]] && exit 0
[[ "$session" != wt/* ]] && exit 0

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/wt-pr"
mkdir -p "$cache_dir" || exit 0

# Replace slashes so the session name maps to a single file.
cache_file="$cache_dir/${session//\//__}"

# Resolve worktree path via the nvim window's pane cwd. The pane was launched
# with `tmux new-session -c $wt_path -n nvim "nvim .; exec zsh"`, so its OS-level
# cwd stays at the worktree root regardless of nvim's internal :cd.
wt_path="$(tmux display-message -p -t "${session}:nvim" '#{pane_current_path}' 2>/dev/null)"
[[ -z "$wt_path" || ! -d "$wt_path" ]] && exit 0

branch="$(git -C "$wt_path" branch --show-current 2>/dev/null)"
[[ -z "$branch" ]] && exit 0

# One PR per branch (most recent if multiple). `--state all` covers open/closed/merged.
pr_json="$(cd "$wt_path" && gh pr list --head "$branch" --state all --limit 1 \
  --json number,state,isDraft,reviewDecision 2>/dev/null)"
[[ -z "$pr_json" || "$pr_json" == "[]" ]] && { : > "$cache_file"; exit 0; }

# Extract fields, replacing null/empty with `-` for stable positional parsing.
read -r number state draft review <<<"$(printf '%s' "$pr_json" | jq -r '
  def blank: . as $v | if ($v == null or $v == "") then "-" else $v end;
  .[0] | "\(.number | blank) \(.state | blank) \(.isDraft | blank) \(.reviewDecision | blank)"')"

printf '%s %s %s %s\n' "$number" "$state" "$draft" "$review" > "$cache_file"
