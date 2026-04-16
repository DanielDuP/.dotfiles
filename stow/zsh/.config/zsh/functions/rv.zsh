# rv — git worktree + tmux session manager for reviewing remote branches
#
# Usage:
#   rv new <branch> [--agent claude|opencode]
#   rv ls
#   rv rm <name>
#   rv help

# Config
RV_DEFAULT_AGENT="claude"

# Helpers
_rv_repo_root() {
  local git_common_dir
  git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  if [[ "$git_common_dir" == ".git" ]]; then
    git rev-parse --show-toplevel
  else
    dirname "$git_common_dir"
  fi
}

_rv_repo_name() {
  basename "$(_rv_repo_root)"
}

_rv_base_dir() {
  local root
  root="$(_rv_repo_root)" || return 1
  echo "$(dirname "$root")/.rv/$(_rv_repo_name)"
}

_rv_session_name() {
  echo "rv/$(_rv_repo_name)/$1"
}

# Subcommands
_rv_new() {
  local branch="" agent="" name=""

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        if [[ -n "$2" && "$2" != --* ]]; then
          agent="$2"
          shift 2
        else
          agent="$RV_DEFAULT_AGENT"
          shift
        fi
        ;;
      -*) echo "rv new: unknown option $1"; return 1 ;;
      *) branch="$1"; shift ;;
    esac
  done

  if [[ -z "$branch" ]]; then
    echo "Usage: rv new <branch> [--agent claude|opencode]"
    return 1
  fi

  # Strip remote prefix if provided (e.g. origin/feature → feature)
  name="${branch#origin/}"

  local repo_root rv_base rv_path session
  repo_root="$(_rv_repo_root)" || { echo "rv: not in a git repo"; return 1; }
  rv_base="$(_rv_base_dir)"
  rv_path="$rv_base/$name"
  session="$(_rv_session_name "$name")"

  # If worktree already exists, switch to it (create session if needed)
  if [[ -d "$rv_path" ]]; then
    if ! tmux has-session -t "$session" 2>/dev/null; then
      tmux new-session -d -s "$session" -c "$rv_path" -n "nvim" "nvim .; exec zsh"
      if [[ -n "$agent" ]]; then
        tmux new-window -t "$session" -n "agent" -c "$rv_path" "$agent; exec zsh"
      else
        tmux new-window -t "$session" -n "agent" -c "$rv_path"
      fi
      tmux new-window -t "$session" -n "shell" -c "$rv_path"
      tmux select-window -t "$session:agent"
      echo "rv: recreated session for existing review '$name'"
    else
      echo "rv: switching to existing review '$name'"
    fi

    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$session"
    else
      tmux attach-session -t "$session"
    fi
    return 0
  fi

  # Fetch latest from remote
  echo "rv: fetching from remote..."
  git -C "$repo_root" fetch origin "$name" 2>/dev/null || git -C "$repo_root" fetch origin 2>/dev/null

  # Verify the remote branch exists
  if ! git -C "$repo_root" rev-parse --verify "origin/$name" &>/dev/null; then
    echo "rv: remote branch 'origin/$name' not found"
    return 1
  fi

  # Create worktree tracking the remote branch
  mkdir -p "$(dirname "$rv_path")"
  if git -C "$repo_root" rev-parse --verify "$name" &>/dev/null; then
    # Local branch exists — use it
    if ! git -C "$repo_root" worktree add "$rv_path" "$name" 2>&1; then
      echo "rv: failed to create worktree"
      return 1
    fi
  else
    # Create local branch tracking remote
    if ! git -C "$repo_root" worktree add -b "$name" "$rv_path" "origin/$name" 2>&1; then
      echo "rv: failed to create worktree"
      return 1
    fi
  fi

  # Ensure tracking is set up
  git -C "$rv_path" branch --set-upstream-to="origin/$name" "$name" 2>/dev/null

  # Create tmux session with 3 windows: nvim, agent, shell
  tmux new-session -d -s "$session" -c "$rv_path" -n "nvim" "nvim .; exec zsh"

  if [[ -n "$agent" ]]; then
    tmux new-window -t "$session" -n "agent" -c "$rv_path" "$agent; exec zsh"
  else
    tmux new-window -t "$session" -n "agent" -c "$rv_path"
  fi

  tmux new-window -t "$session" -n "shell" -c "$rv_path"

  # Select agent window
  tmux select-window -t "$session:agent"

  # Switch or attach
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

_rv_ls() {
  local repo_root rv_base repo_name
  repo_root="$(_rv_repo_root)" || { echo "rv: not in a git repo"; return 1; }
  rv_base="$(_rv_base_dir)"
  repo_name="$(_rv_repo_name)"

  if [[ ! -d "$rv_base" ]]; then
    echo "No reviews for $repo_name"
    return 0
  fi

  printf "%-45s %-45s %-10s %s\n" "NAME" "BRANCH" "SESSION" "PATH"
  printf "%-45s %-45s %-10s %s\n" "----" "------" "-------" "----"

  local wt_path wt_name branch session status
  git -C "$repo_root" worktree list --porcelain | grep '^worktree ' | while read -r _ wt_path; do
    [[ "$wt_path" == "$rv_base"/* ]] || continue
    wt_name="${wt_path#$rv_base/}"
    branch="$(git -C "$wt_path" branch --show-current 2>/dev/null || echo "???")"
    session="$(_rv_session_name "$wt_name")"

    if tmux has-session -t "$session" 2>/dev/null; then
      status="alive"
    else
      status="dead"
    fi

    printf "%-45s %-45s %-10s %s\n" "$wt_name" "$branch" "$status" "$wt_path"
  done
}

_rv_rm() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: rv rm <name>"
    return 1
  fi

  local repo_root rv_base rv_path session
  repo_root="$(_rv_repo_root)" || { echo "rv: not in a git repo"; return 1; }
  rv_base="$(_rv_base_dir)"
  rv_path="$rv_base/$name"
  session="$(_rv_session_name "$name")"

  # Refuse if we're inside the worktree being removed
  local current_dir
  current_dir="$(pwd -P)"
  if [[ "$current_dir" == "$rv_path"* ]]; then
    echo "rv: can't remove '$name' — you're currently inside it"
    echo "    switch to another session first"
    return 1
  fi

  # Warn about uncommitted changes
  if [[ -d "$rv_path" ]]; then
    local dirty
    dirty="$(git -C "$rv_path" status --porcelain 2>/dev/null)"
    if [[ -n "$dirty" ]]; then
      echo "rv: warning — '$name' has uncommitted changes:"
      echo "$dirty"
      echo ""
    fi
  fi

  # Kill tmux session
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux kill-session -t "$session"
    echo "killed session: $session"
  fi

  # Remove worktree
  if [[ -d "$rv_path" ]]; then
    git -C "$repo_root" worktree remove "$rv_path" --force
    echo "removed worktree: $rv_path"
  fi

  git -C "$repo_root" worktree prune

  # Delete local tracking branch
  if git -C "$repo_root" rev-parse --verify "$name" &>/dev/null; then
    if ! git -C "$repo_root" branch -d "$name" 2>/dev/null; then
      echo "rv: branch '$name' has unmerged changes — use 'git branch -D $name' to force delete"
    else
      echo "deleted branch: $name"
    fi
  fi

  # Clean up empty .rv/<repo> dir
  if [[ -d "$rv_base" ]] && [[ -z "$(ls -A "$rv_base" 2>/dev/null)" ]]; then
    rmdir "$rv_base"
  fi
}

_rv_help() {
  cat <<'EOF'
rv — git worktree + tmux session manager for reviews

Commands:
  rv new <branch> [--agent claude|opencode]
      Fetch a remote branch, create a worktree tracking it, and open a
      tmux session with nvim, agent, and shell windows.

  rv ls
      List review worktrees for the current repo with session status.

  rv rm <name>
      Remove review worktree, kill session, delete local tracking branch.

Tmux keybindings:
  prefix+r    Create a new review session (prompts for branch and agent)
  prefix+R    Fuzzy-pick a review session (with delta diff preview)
EOF
}

# Main dispatch
rv() {
  local cmd="${1:-help}"
  shift 2>/dev/null

  case "$cmd" in
    new)    _rv_new "$@" ;;
    ls)     _rv_ls "$@" ;;
    rm)     _rv_rm "$@" ;;
    help|*) _rv_help ;;
  esac
}
