#!/usr/bin/env zsh
# ==============================================================================
# Set some macOS preferences
# Heavily inspired by https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# and https://github.com/beyarkay/dotfiles/
# ==============================================================================

# Parse flags
AUTO_YES=false
[[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]] && AUTO_YES=true

# Function to ask for confirmation with a description
function ask_confirmation() {
    [[ "$AUTO_YES" == true ]] && return 0
    local choice
    read "choice?Do you want to run: $1? (y/n): "
    [[ "$choice" =~ ^[Yy] ]]
}

# Ensure a cask is installed (no-op if already present)
function ensure_cask() {
    if ! brew list --cask "$1" &>/dev/null; then
        brew install --cask "$1"
    fi
}

# ========================
# Set mac system settings
# ========================
if ask_confirmation "Set mac system settings"; then
	# Close any open System Settings panes, to prevent them from overriding
	# settings we're about to change
	osascript -e 'tell application "System Settings" to quit'

	# Trackpad: enable tap to click for this user and for the login screen
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

	# Trackpad: 3-finger swipe down for App Exposé
	defaults write com.apple.dock showAppExposeGestureEnabled -bool true
	defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2

	# Disable the sound effects on boot (Intel Macs only)
	if [[ "$(uname -m)" != "arm64" ]]; then
		sudo nvram SystemAudioVolume=" "
	fi

	# Require password immediately after sleep or screen saver begins
	# Note: On macOS Ventura+, configure via System Settings → Lock Screen
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0

	# Save screenshots to the desktop
	defaults write com.apple.screencapture location -string "${HOME}/Desktop"

	# Disable shadow in screenshots
	defaults write com.apple.screencapture disable-shadow -bool true

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

	# Finder: show hidden/dot files
	defaults write com.apple.finder AppleShowAllFiles -bool true

	# Finder: show status bar
	defaults write com.apple.finder ShowStatusBar -bool false

	# Finder: show path bar
	defaults write com.apple.finder ShowPathbar -bool true

	# Display full POSIX path as Finder window title
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool false

	# Keep folders on top when sorting by name
	defaults write com.apple.finder _FXSortFoldersFirst -bool true

	# When performing a search, search the current folder by default
	defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

	# Disable the warning when changing a file extension
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

	# Automatically open a new Finder window when a volume is mounted
	defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
	defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
	defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

	# Use list view in all Finder windows by default
	# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	# Show the ~/Library folder
	# chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

	# Set the icon size of Dock items to 36 pixels
	defaults write com.apple.dock tilesize -int 36

	# Wipe all (default) app icons from the Dock
	# This is only really useful when setting up a new Mac, or if you don't use
	# the Dock to launch apps.
	defaults write com.apple.dock persistent-apps -array

	# Show only open applications in the Dock
	# Note: static-only removes persistent-others (Downloads stack etc.), so we
	# keep it off and just wipe persistent-apps above instead
	defaults write com.apple.dock static-only -bool false

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true

	# Make Dock icons of hidden applications translucent
	defaults write com.apple.dock showhidden -bool true

	# Remove dock autohide delay
	defaults write com.apple.dock autohide-delay -float 0

	# Add Downloads folder to the Dock (right side, as a stack sorted by date)
	defaults write com.apple.dock persistent-others -array \
		"<dict>
			<key>tile-data</key>
			<dict>
				<key>file-data</key>
				<dict>
					<key>_CFURLString</key>
					<string>file://${HOME}/Downloads/</string>
					<key>_CFURLStringType</key>
					<integer>15</integer>
				</dict>
				<key>file-label</key>
				<string>Downloads</string>
				<key>file-type</key>
				<integer>2</integer>
				<key>arrangement</key>
				<integer>2</integer>
				<key>displayas</key>
				<integer>0</integer>
				<key>showas</key>
				<integer>1</integer>
			</dict>
			<key>tile-type</key>
			<string>directory-tile</string>
		</dict>"

	# Show battery percentage in menu bar
	defaults write com.apple.controlcenter BatteryShowPercentage -bool true

	# Set dark mode
	defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

	# Restart the System?
	/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

	# Restart all the affected apps
	for app in "cfprefsd" \
		"Dock" \
		"Finder" \
		"SystemUIServer" \
		"ControlCenter"; do
		killall "${app}" &> /dev/null
	done

fi

# ================
# Install homebrew
# ================
if ! command -v brew &>/dev/null; then
	if ask_confirmation "Install homebrew"; then
		echo -e "$RESET$BOLD Installing homebrew$RESET"
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		echo -e "$BOLD Homebrew installation finished$RESET"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
else
	echo "Homebrew already installed, skipping."
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# ================
# Install packages
# ================
if ask_confirmation "Install packages"; then
    brew install \
    git \
    gh \
    bat \
    fzf \
    fd \
    tmux \
    reattach-to-user-namespace \
    recast \
    htop \
    gnu-sed \
    grep
fi

# ==========================
# Authenticate GitHub CLI
# ==========================
if command -v gh &>/dev/null; then
	if ask_confirmation "Authenticate GitHub CLI (gh auth login)"; then
		gh auth login
	fi
fi

# =============
# Install casks
# =============
if ask_confirmation "Install casks"; then
    brew install --cask \
    whatsapp \
    telegram \
    raycast \
    rectangle \
    transmission \
    vlc \
    macs-fan-control \
    iterm2 \
    jetbrains-toolbox \
    visual-studio-code \
    discord \
    todoist \
    qlmarkdown \
    syntax-highlight \
    obsidian \
    signal
fi

# ==========================================
# Install document/notebook tools (optional)
# ==========================================
if ask_confirmation "Install document/notebook tools (optional)"; then
    brew install \
    miniconda \
    pandoc
    brew install --cask mactex-no-gui
fi

# =================
# Install Nerdfonts
# =================
if ask_confirmation "Install Nerdfonts"; then
    brew install --cask font-jetbrains-mono-nerd-font font-fira-code-nerd-font
fi

# ==================================
# Enable QuickLook plugins
# ==================================
# qlmarkdown and syntax-highlight require removing quarantine to work
if [[ -d "/Applications/QLMarkdown.app" ]]; then
	xattr -r -d com.apple.quarantine /Applications/QLMarkdown.app 2>/dev/null
fi
if [[ -d "/Applications/Syntax Highlight.app" ]]; then
	xattr -r -d com.apple.quarantine "/Applications/Syntax Highlight.app" 2>/dev/null
fi
echo "NOTE: QuickLook plugins may need manual approval in:"
echo "	System Settings → Privacy & Security → Extensions → Quick Look"

# ==========================
# Install and setup iTerm2
# ==========================
if ask_confirmation "Install and setup iTerm2"; then
    ensure_cask iterm2

	# Kill iTerm2 if running (it overwrites preferences on quit)
	killall iTerm2 2>/dev/null && sleep 1

    # Import saved preferences if they exist in the repo
    if [[ -f "${HOME}/.dotfiles/iterm2/com.googlecode.iterm2.plist" ]]; then
        echo "Importing iTerm2 preferences from dotfiles..."
		# Remove active prefs so iTerm2 reads from custom folder on next launch
		rm -f "${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
		defaults delete com.googlecode.iterm2 2>/dev/null
        defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${HOME}/.dotfiles/iterm2"
        defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    else
        echo "No saved iTerm2 preferences found. Importing color scheme..."
        open "${HOME}/.dotfiles/iterm2/One Dark whiter.itermcolors"
    fi

    echo ""
    echo "To save your iTerm2 settings (keybindings, profiles, etc.) for future machines:"
    echo "  mkdir -p ~/.dotfiles/iterm2"
    echo "  cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/.dotfiles/iterm2/"
    echo "  cd ~/.dotfiles && git add iterm2/ && git commit -m 'feat: Save iTerm2 preferences'"
fi

# ==========================
# Setup Firefox
# ==========================
if ask_confirmation "Setup Firefox (userChrome, extensions, userscripts)"; then
	if [[ ! -d "/Applications/Firefox.app" ]]; then
		echo "Firefox not found. Install it with:"
		echo "	brew install --cask firefox"
		read "?Press enter once Firefox is installed..."
	fi

	# Find Firefox profile directory (created on first launch)
	FF_PROFILES="$HOME/Library/Application Support/Firefox/Profiles"
	if [[ ! -d "$FF_PROFILES" ]]; then
		echo "Firefox profile not found. Launching Firefox to create one..."
		open -a Firefox
		read "?Close Firefox and press enter once it has created a profile..."
	fi

	FF_PROFILE=$(find "$FF_PROFILES" -maxdepth 1 -name "*.default-release" 2>/dev/null | head -1)
	if [[ -z "$FF_PROFILE" ]]; then
		FF_PROFILE=$(find "$FF_PROFILES" -maxdepth 1 -type d ! -name Profiles | head -1)
	fi

	if [[ -n "$FF_PROFILE" ]]; then
		# Symlink user.js (Firefox preferences)
		if [[ -f "$HOME/.dotfiles/firefox/user.js" ]]; then
			ln -sf "$HOME/.dotfiles/firefox/user.js" "$FF_PROFILE/user.js"
			echo "✓ user.js symlinked"
		fi

		# Symlink chrome directory (userChrome.css + supporting CSS)
		if [[ -d "$HOME/.dotfiles/firefox/chrome" ]]; then
			rm -rf "$FF_PROFILE/chrome"
			ln -sf "$HOME/.dotfiles/firefox/chrome" "$FF_PROFILE/chrome"
			echo "✓ chrome/ directory symlinked"
		fi

		# Auto-install extensions via policies.json
		if [[ -f "$HOME/.dotfiles/firefox/policies.json" ]]; then
			sudo mkdir -p "/Applications/Firefox.app/Contents/Resources/distribution"
			sudo cp "$HOME/.dotfiles/firefox/policies.json" "/Applications/Firefox.app/Contents/Resources/distribution/"
			echo "✓ policies.json deployed (extensions will auto-install on next launch)"
		fi
	else
		echo "WARNING: Could not find Firefox profile directory."
	fi

	echo ""
	echo "━━━ Firefox: What to import manually ━━━"
	echo ""
	if [[ -f "$HOME/.dotfiles/firefox/sideberry-settings.json" ]]; then
		echo "	Sideberry: Settings → Help → Import → ~/.dotfiles/firefox/sideberry-settings.json"
	fi
	if [[ -f "$HOME/.dotfiles/firefox/tampermonkey-backup.zip" ]]; then
		echo "	Tampermonkey: Dashboard → Utilities → Zip → Import → ~/.dotfiles/firefox/tampermonkey-backup.zip"
	fi

	echo ""
	echo "━━━ Firefox: How to export FROM your old machine ━━━"
	echo ""
	echo "	~/.dotfiles/firefox/export.sh"
	echo ""
	echo "	# Then manually:"
	echo "	# Sideberry → Settings → Help → Export → save as ~/.dotfiles/firefox/sideberry-settings.json"
	echo "	# Tampermonkey → Dashboard → Utilities → Zip → Export → save as ~/.dotfiles/firefox/tampermonkey-backup.zip"
	echo ""
fi

# ========================
# Raycast configuration
# ========================
if [[ -d "/Applications/Raycast.app" ]]; then
	echo ""
	echo "━━━ Raycast: Import settings ━━━"
	echo ""
	if ls "$HOME/.dotfiles/raycast/"*.rayconfig 1>/dev/null 2>&1; then
		echo "	Import: Raycast → Settings (⌘,) → Advanced → Import"
		echo "	File: ~/.dotfiles/raycast/*.rayconfig"
	else
		echo "	No .rayconfig found. Export from old machine:"
		echo "	Raycast → Settings (⌘,) → Advanced → Export"
		echo "	Save to: ~/.dotfiles/raycast/"
	fi
	echo ""
fi

# ===================
# Install Starship.rs
# ===================
if ask_confirmation "Install Starship.rs prompt"; then
    brew install starship
fi

# ============
# Install rust
# ============
if ask_confirmation "Install Rust using rustup"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
