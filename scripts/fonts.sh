fonts=(
	font-jetbrains-mono-nerd-font
)

install_fonts() {
	info "Installing fonts..."
	install_brew_casks "${fonts[@]}"
}
