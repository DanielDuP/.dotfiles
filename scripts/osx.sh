setup_osx() {
	info "Configuring MacOS default settings"

	# Hide hard drives on desktop
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

	# Hide removable media hard drives on desktop
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

	# Hide mounted servers on desktop
	defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

	# Hide icons on desktop
	defaults write com.apple.finder CreateDesktop -bool false

	# Show path bar
	defaults write com.apple.finder ShowPathbar -bool true

	# Show hidden files inside the finder
	defaults write com.apple.finder "AppleShowAllFiles" -bool true

	# Show Status Bar
	defaults write com.apple.finder "ShowStatusBar" -bool true

	# Set search scope to current folder
	defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

	# Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

	# Add a context menu item for showing the Web Inspector in web views
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

	# Have the Dock show only active apps
	defaults write com.apple.dock static-only -bool true

	# Set Dock autohide
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock largesize -float 128
	defaults write com.apple.dock "minimize-to-application" -bool true
	defaults write com.apple.dock tilesize -float 32

	# Disable startup sound
	sudo nvram SystemAudioVolume=%01

	# # Enable ssh agent on start up
	#info "Enabling ssh agent on start up with launchctl"
	#cp "$HOME/.dotfiles/macos/com.openssh.ssh-agent.plist" "$HOME/Library/LaunchAgents/"
	#launchctl load "$HOME/Library/LaunchAgents/com.openssh.ssh-agent.plist"
	#launchctl enable "$HOME/Library/LaunchAgents/com.openssh.ssh-agent.plist"
}
