#!/usr/bin/env bash
# ==============================================================================
# Set some macOS preferences
# Heavily inspired by https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# and https://github.com/beyarkay/dotfiles/
# ==============================================================================

# Function to ask for confirmation with a description
function ask_confirmation() {
    local description="$1"
    read -p "Do you want to run the following section? (y/n): $description : " choice
    case "$choice" in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

# ========================
# Set mac system settings
# ========================
if ask_confirmation "Set mac system settings"; then
	# Close any open System Preferences panes, to prevent them from overriding
	# settings we're about to change
	osascript -e 'tell application "System Preferences" to quit'

	# Trackpad: enable tap to click for this user and for the login screen
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

	# Disable the sound effects on boot
	sudo nvram SystemAudioVolume=" "

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0

	# Save screenshots to the desktop
	defaults write com.apple.screencapture location -string "${HOME}/Desktop"

	# Disable shadow in screenshots
	defaults write com.apple.screencapture disable-shadow -bool true

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

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
	defaults write com.apple.dock static-only -bool true

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true

	# Make Dock icons of hidden applications translucent
	defaults write com.apple.dock showhidden -bool true

	# Remove dock autohide delay
	defaults write com.apple.dock autohide-delay -float 0

	# Restart the System?
	/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

	# Restart all the affected apps
	for app in "cfprefsd" \
		"Dock" \
		"Finder" \
		"SystemUIServer" \
		"iCal"; do
		killall "${app}" &> /dev/null
	done

fi

# ================
# Install homebrew
# ================
if ask_confirmation "Install homebrew"; then
    echo -e "$RESET$BOLD Installing homebrew$RESET"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo -e "$BOLD Homebrew installation finished$RESET"
fi

# ================
# Install packages
# ================
if ask_confirmation "Install packages"; then
    brew install \
    git \
    exa \
    miniconda \
    pandoc \
    gh
fi

# =============
# Install casks
# =============
if ask_confirmation "Install casks"; then
    brew install --cask --no-quarantine \
    whatsapp \
    telegram \
    rectangle \
    transmission \
    vlc \
    macs-fan-control \
    iterm2 \
    jetbrains-toolbox \
    visual-studio-code \
    mactex-no-gui \
    discord \
    todoist \
    qlmarkdown \
    syntax-highlight
fi

# =================
# Install Nerdfonts
# =================
if ask_confirmation "Install Nerdfonts"; then
    brew tap homebrew/cask-fonts && brew install --cask  font-jetbrains-mono-nerd-font font-fira-code-nerd-font
fi

# ==========================
# Install and setup iTerm2
# ==========================
if ask_confirmation "Install and setup iTerm2"; then
    open "${HOME}/.dotfiles/One Dark whiter.itermcolors"
    conda init "$(basename "${SHELL}")"
fi

# ==========================
# Symlink Sublim Preferences
# ==========================
if ask_confirmation "Symlink Sublime Preferences"; then
    ln -s ~/.dotfiles/Preferences.sublime_settings /Users/luchayward/Library/Application Support/Sublime Text/Packages/User/
fi
