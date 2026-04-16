# restow — re-stow all dotfile packages from ~/.dotfiles/stow
#
# Usage:
#   restow          Restow all packages
#   restow nvim     Restow specific package(s)

restow() {
  local stow_dir="$HOME/.dotfiles/stow"

  if [[ ! -d "$stow_dir" ]]; then
    echo "restow: $stow_dir not found"
    return 1
  fi

  local packages=("$@")
  if [[ ${#packages[@]} -eq 0 ]]; then
    packages=($(find "$stow_dir" -mindepth 1 -maxdepth 1 -type d -not -empty | xargs -n1 basename))
  fi

  echo "restowing: ${packages[*]}"
  stow -d "$stow_dir" --no-folding --restow --target "$HOME" ${packages[@]}
}
