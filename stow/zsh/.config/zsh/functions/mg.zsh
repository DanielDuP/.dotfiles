# Management sessions use existing directories, never Git worktrees.
# mg / mg pick: select a session; mg ls: list sessions
# mg new [name] [--dir <directory>] [--prompt <text>] [--detach]
mg() {
  local action="${1:-pick}"
  (( $# )) && shift
  case "$action" in
    pick)
      zsh "$HOME/.tmux/scripts/mg-picker.sh"
      ;;
    ls)
      tmux list-sessions -f '#{m:mg/*,#{session_name}}' \
        -F '#{session_name}  #{session_path}'
      ;;
    new)
      local name="" dir="$PWD" prompt="" detach=0
      while (( $# )); do
        case "$1" in
          --dir|--prompt)
            if (( $# < 2 )); then
              print -u2 -- "mg: $1 requires a value"
              return 1
            fi
            if [[ "$1" == --dir ]]; then dir="$2"; else prompt="$2"; fi
            shift 2
            ;;
          --detach) detach=1; shift ;;
          -*) print -u2 -- "mg: unknown option $1"; return 1 ;;
          *)
            [[ -z "$name" ]] || { print -u2 -- 'mg: expected one name'; return 1; }
            name="$1"
            shift
            ;;
        esac
      done
      [[ -d "$dir" ]] || { print -u2 -- "mg: directory not found: $dir"; return 1; }
      dir="${dir:A}"
      if [[ -z "$name" ]]; then
        name="${dir:t}"
        name="${name//[^a-zA-Z0-9_-]/_}"
      fi
      # Dots and colons have special meaning in tmux targets.
      if [[ -z "${name// /}" || "$name" == *[^a-zA-Z0-9_\ -]* ]]; then
        print -u2 -- 'mg: use a name containing letters, numbers, spaces, hyphens, or underscores'
        return 1
      fi
      local session="mg/$name" id command launch
      id=$(tmux display-message -p -t "=$session:" '#{session_id}' 2>/dev/null) || id=""
      if [[ -z "$id" ]]; then
        command='opencode'
        [[ -z "$prompt" ]] || command+=" --prompt ${(q)prompt}"
        command+='; exec zsh'
        printf -v launch 'exec zsh -ic %q' "$command"
        id=$(tmux new-session -d -P -F '#{session_id}' -s "$session" \
          -c "$dir" -n opencode "$launch") || return
      fi
      if (( detach )); then
        print -r -- "mg: $session ready (detached)"
      elif [[ -n "${TMUX:-}" ]]; then
        local -a client_args
        [[ -z "${MG_CLIENT:-}" ]] || client_args=(-c "$MG_CLIENT")
        tmux switch-client "${client_args[@]}" -t "$id"
      else
        tmux attach-session -t "$id"
      fi
      ;;
    help|--help|-h)
      print -r -- 'mg [pick|ls]'
      print -r -- 'mg new [name] [--dir <directory>] [--prompt <text>] [--detach]'
      ;;
    *) print -u2 -- "mg: unknown command $action (see mg help)"; return 1 ;;
  esac
}
