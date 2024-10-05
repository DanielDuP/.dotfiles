apps=(
	discord
	docker
	firefox
	google-chrome
	rectangle # Window util
	slack
	visual-studio-code
	vlc
	kitty
	android-studio
	obsidian
)

mas_apps=(
	"768053424" # Gapplin (svg viewer)
)

install_macos_apps() {
	info "Installing macOS apps..."
	install_brew_casks "${apps[@]}"
}

install_masApps() {
	info "Installing App Store apps..."
	for app in "${mas_apps[@]}"; do
		mas install "$app"
	done
}
