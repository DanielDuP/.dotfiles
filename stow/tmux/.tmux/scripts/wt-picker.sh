#!/usr/bin/env zsh
# wt-picker — fuzzy worktree session picker with time-grouped display

set -uo pipefail

# Color palette for repos
typeset -A COLOR_MAP
COLORS=(36 33 35 32 34 31) # cyan yellow magenta green blue red
COLOR_IDX=0

# PR cache populated by wt-pr-refresh.sh on session switch.
PR_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wt-pr"

# Returns an ANSI-colored "#<num>" badge (padded to 7 chars) for the session,
# or 7 spaces if no cache entry / no PR.
pr_badge() {
  local session="$1"
  local file="$PR_CACHE_DIR/${session//\//__}"
  [[ -s "$file" ]] || { printf '%-7s' ""; return; }

  local number state draft review
  read -r number state draft review < "$file"
  [[ -z "$number" || "$number" == "-" ]] && { printf '%-7s' ""; return; }

  local color
  if [[ "$draft" == "true" ]]; then
    color=90 # grey
  elif [[ "$state" == "CLOSED" || "$state" == "MERGED" ]]; then
    color=31 # red
  elif [[ "$review" == "APPROVED" ]]; then
    color=32 # green
  else
    color=33 # yellow (open, not approved)
  fi
  printf '\033[%sm%-7s\033[0m' "$color" "#$number"
}

# Time boundaries
TODAY_START=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 00:00:00" +%s)
YESTERDAY_START=$((TODAY_START - 86400))
WEEK_START=$((TODAY_START - 604800))

time_label() {
  local ts=$1
  if (( ts >= TODAY_START )); then echo "today"
  elif (( ts >= YESTERDAY_START )); then echo "yesterday"
  elif (( ts >= WEEK_START )); then echo "this week"
  else echo "older"
  fi
}

# Collect sessions into array (avoids pipe subshell issues with associative arrays)
sessions=("${(@f)$(tmux list-sessions -F '#{session_last_attached} #{session_name}' | grep ' wt/' | sort -rn)}")

[[ ${#sessions[@]} -eq 0 ]] && { echo "No worktree sessions"; exit 0; }

# Build output lines in an array
typeset -a lines
last_group=""

for line in "${sessions[@]}"; do
  ts="${line%% *}"
  session_name="${line#* }"

  group="$(time_label "$ts")"
  if [[ "$group" != "$last_group" ]]; then
    [[ "$group" != "today" ]] && lines+=("$(printf 'HEADER\t\033[1;37m── %s ──\033[0m' "$group")")
    last_group="$group"
  fi

  # Parse: wt/<repo>/<user>/<rest...>
  stripped="${session_name#wt/}"
  repo="${stripped%%/*}"
  rest="${stripped#*/}"
  rest="${rest#*/}" # strip username

  # Assign color per repo
  if [[ -z "${COLOR_MAP[$repo]:-}" ]]; then
    COLOR_IDX=$((COLOR_IDX + 1))
    COLOR_MAP[$repo]="${COLORS[$(( (COLOR_IDX - 1) % ${#COLORS[@]} + 1 ))]}"
  fi
  c="${COLOR_MAP[$repo]}"

  # Split rest into columns
  cols=""
  for part in "${(@s:/:)rest}"; do
    cols+="$(printf '%-20s' "$part")"
  done

  badge="$(pr_badge "$session_name")"

  lines+=("$(printf '%s\t%s \033[%sm%-25s %s\033[0m' "$session_name" "$badge" "$c" "$repo" "$cols")")
done

# Feed to fzf
selected=$(printf '%s\n' "${lines[@]}" | fzf --ansi --reverse --no-header \
    --with-nth=2 --delimiter=$'\t' \
    --preview 'tmux capture-pane -t {1}:agent -p -e 2>/dev/null | tail -n ${FZF_PREVIEW_LINES:-40} || echo "(no agent pane)"' \
    --preview-window=right:60% \
  | cut -f1)

if [[ -n "$selected" && "$selected" != "HEADER" ]]; then
  tmux switch-client -t "$selected"
fi
