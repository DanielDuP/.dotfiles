# wt — git worktree + tmux session manager for parallel agentic coding
#
# Usage:
#   wt new <name> [--agent claude|opencode] [--branch <base>]
#   wt ls
#   wt rm <name>
#   wt help

# Config
WT_DEFAULT_AGENT="claude"

# Helpers
_wt_repo_root() {
  local git_common_dir
  git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  # For regular repos, --git-common-dir returns .git — use --show-toplevel
  # For worktrees, it returns the shared .git dir — derive root from that
  if [[ "$git_common_dir" == ".git" ]]; then
    git rev-parse --show-toplevel
  else
    # git-common-dir is absolute path to shared .git dir
    dirname "$git_common_dir"
  fi
}

_wt_repo_name() {
  basename "$(_wt_repo_root)"
}

_wt_base_dir() {
  local root
  root="$(_wt_repo_root)" || return 1
  echo "$(dirname "$root")/.wt/$(_wt_repo_name)"
}

_wt_session_name() {
  echo "wt/$(_wt_repo_name)/$1"
}

# Subcommands
_wt_new() {
  local name="" agent="" base="HEAD"

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        if [[ -n "$2" && "$2" != --* ]]; then
          agent="$2"
          shift 2
        else
          agent="$WT_DEFAULT_AGENT"
          shift
        fi
        ;;
      --branch) base="$2"; shift 2 ;;
      -*) echo "wt new: unknown option $1"; return 1 ;;
      *) name="$1"; shift ;;
    esac
  done

  if [[ -z "$name" ]]; then
    echo "Usage: wt new <name> [--agent claude|opencode] [--branch <base>]"
    return 1
  fi

  # Prepend git username to task name
  local git_user
  git_user="$(git config user.name 2>/dev/null | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
  if [[ -n "$git_user" ]]; then
    name="$git_user/$name"
  fi

  local repo_root wt_base wt_path session
  repo_root="$(_wt_repo_root)" || { echo "wt: not in a git repo"; return 1; }
  wt_base="$(_wt_base_dir)"
  wt_path="$wt_base/$name"
  session="$(_wt_session_name "$name")"

  # If worktree already exists, switch to it (create session if needed)
  if [[ -d "$wt_path" ]]; then
    if ! tmux has-session -t "$session" 2>/dev/null; then
      # Worktree exists but session is dead — recreate session
      tmux new-session -d -s "$session" -c "$wt_path" -n "nvim" "nvim .; exec zsh"
      if [[ -n "$agent" ]]; then
        tmux new-window -t "$session" -n "agent" -c "$wt_path" "$agent; exec zsh"
      else
        tmux new-window -t "$session" -n "agent" -c "$wt_path"
      fi
      tmux new-window -t "$session" -n "shell" -c "$wt_path"
      tmux select-window -t "$session:agent"
      echo "wt: recreated session for existing worktree '$name'"
    else
      echo "wt: switching to existing worktree '$name'"
    fi

    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$session"
    else
      tmux attach-session -t "$session"
    fi
    return 0
  fi

  # Create worktree — use existing branch if it exists, otherwise create new
  mkdir -p "$(dirname "$wt_path")"
  if git -C "$repo_root" rev-parse --verify "$name" &>/dev/null; then
    if ! git -C "$repo_root" worktree add "$wt_path" "$name" 2>&1; then
      echo "wt: failed to create worktree"
      return 1
    fi
  else
    if ! git -C "$repo_root" worktree add -b "$name" "$wt_path" "$base" 2>&1; then
      echo "wt: failed to create worktree"
      return 1
    fi
  fi

  # Create tmux session with 3 windows: nvim, agent, shell
  # Commands are passed directly as window processes — no shell init race.
  # "cmd; exec zsh" gives a shell back when the command exits.
  tmux new-session -d -s "$session" -c "$wt_path" -n "nvim" "nvim .; exec zsh"

  if [[ -n "$agent" ]]; then
    tmux new-window -t "$session" -n "agent" -c "$wt_path" "$agent; exec zsh"
  else
    tmux new-window -t "$session" -n "agent" -c "$wt_path"
  fi

  tmux new-window -t "$session" -n "shell" -c "$wt_path"

  # Select agent window
  tmux select-window -t "$session:agent"

  # Switch or attach
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

_wt_ls() {
  local repo_root wt_base repo_name
  repo_root="$(_wt_repo_root)" || { echo "wt: not in a git repo"; return 1; }
  wt_base="$(_wt_base_dir)"
  repo_name="$(_wt_repo_name)"

  if [[ ! -d "$wt_base" ]]; then
    echo "No worktrees for $repo_name"
    return 0
  fi

  printf "%-45s %-45s %-10s %s\n" "NAME" "BRANCH" "SESSION" "PATH"
  printf "%-45s %-45s %-10s %s\n" "----" "------" "-------" "----"

  local wt_path wt_name branch session status
  git -C "$repo_root" worktree list --porcelain | grep '^worktree ' | while read -r _ wt_path; do
    # Only show worktrees under our .wt base dir
    [[ "$wt_path" == "$wt_base"/* ]] || continue
    wt_name="${wt_path#$wt_base/}"
    branch="$(git -C "$wt_path" branch --show-current 2>/dev/null || echo "???")"
    session="$(_wt_session_name "$wt_name")"

    if tmux has-session -t "$session" 2>/dev/null; then
      status="alive"
    else
      status="dead"
    fi

    printf "%-45s %-45s %-10s %s\n" "$wt_name" "$branch" "$status" "$wt_path"
  done
}

_wt_rm() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: wt rm <name>"
    return 1
  fi

  local repo_root wt_base wt_path session
  repo_root="$(_wt_repo_root)" || { echo "wt: not in a git repo"; return 1; }
  wt_base="$(_wt_base_dir)"
  wt_path="$wt_base/$name"
  session="$(_wt_session_name "$name")"

  # Refuse if we're inside the worktree being removed
  local current_dir
  current_dir="$(pwd -P)"
  if [[ "$current_dir" == "$wt_path"* ]]; then
    echo "wt: can't remove '$name' — you're currently inside it"
    echo "    switch to another session first"
    return 1
  fi

  # Warn about uncommitted changes
  if [[ -d "$wt_path" ]]; then
    local dirty
    dirty="$(git -C "$wt_path" status --porcelain 2>/dev/null)"
    if [[ -n "$dirty" ]]; then
      echo "wt: warning — '$name' has uncommitted changes:"
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
  if [[ -d "$wt_path" ]]; then
    git -C "$repo_root" worktree remove "$wt_path" --force
    echo "removed worktree: $wt_path"
  fi

  git -C "$repo_root" worktree prune

  # Delete branch (warn if unmerged)
  if git -C "$repo_root" rev-parse --verify "$name" &>/dev/null; then
    if ! git -C "$repo_root" branch -d "$name" 2>/dev/null; then
      echo "wt: branch '$name' has unmerged changes — use 'git branch -D $name' to force delete"
    else
      echo "deleted branch: $name"
    fi
  fi

  # Clean up empty .wt/<repo> dir
  if [[ -d "$wt_base" ]] && [[ -z "$(ls -A "$wt_base" 2>/dev/null)" ]]; then
    rmdir "$wt_base"
  fi
}

_wt_help() {
  cat <<'EOF'
wt — git worktree + tmux session manager

Commands:
  wt new <name> [--agent claude|opencode] [--branch <base>]
      Create a worktree and tmux session with agent, lazygit, and shell windows.
      Default base is HEAD.

  wt ls
      List worktrees for the current repo with session status.

  wt rm <name>
      Remove worktree, kill session, delete branch.

Tmux keybindings:
  prefix+w    Fuzzy-pick a worktree session (with delta diff preview)
  prefix+W    Create a new worktree session (prompts for name and agent)
EOF
}

# Main dispatch
wt() {
  local cmd="${1:-help}"
  shift 2>/dev/null

  case "$cmd" in
    new)    _wt_new "$@" ;;
    ls)     _wt_ls "$@" ;;
    rm)     _wt_rm "$@" ;;
    help|*) _wt_help ;;
  esac
}
