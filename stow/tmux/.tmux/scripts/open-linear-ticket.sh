#!/usr/bin/env zsh

branch="$(git -C "${1:-$PWD}" branch --show-current 2>/dev/null)"
ticket="${${branch#*/}%%/*}"

if [[ "$branch" != */* || ! "$ticket" =~ '^[[:alpha:]][[:alnum:]]*-[[:digit:]]+$' ]]; then
  tmux display-message "No Linear ticket found in branch name"
  exit 1
fi

open "https://linear.app/issue/${(U)ticket}"
