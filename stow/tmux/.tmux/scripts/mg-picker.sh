#!/usr/bin/env zsh

set -uo pipefail

if [[ "${1:-}" == --new ]]; then
  source "$HOME/.config/zsh/functions/mg.zsh"
  default="${PWD:t}"
  default="${default//[^a-zA-Z0-9_-]/_}"
  print -r -- "Directory: $PWD"
  read -r "name?Management name [$default]: " || exit 0
  if ! mg new "${name:-$default}"; then
    read -r '?Press Enter to close.'
    exit 1
  fi
  exit 0
fi

rows=$(tmux list-sessions -f '#{m:mg/*,#{session_name}}' \
  -F $'#{session_last_attached}\t#{session_id}\t#{s|^mg/||:session_name}\t#{session_path}' \
  2>/dev/null | sort -rn)

if [[ -z "$rows" ]]; then
  print -r -- 'No management sessions. Use mg new <name> or Ctrl-b G to create one.'
  [[ ! -t 0 ]] || read -r '?Press Enter to close.'
  exit 0
fi

selected=$(print -r -- "$rows" | fzf --reverse \
  --delimiter=$'\t' --with-nth=3 --no-header \
  --preview 'tmux capture-pane -t {2}: -p -e 2>/dev/null' \
  --preview-window=right:60%) || exit 0

[[ -n "$selected" ]] || exit 0
fields=("${(@ps:\t:)selected}")
if [[ -n "${TMUX:-}" ]]; then
  client_args=()
  [[ -z "${MG_CLIENT:-}" ]] || client_args=(-c "$MG_CLIENT")
  tmux switch-client "${client_args[@]}" -t "$fields[2]"
else
  tmux attach-session -t "$fields[2]"
fi
