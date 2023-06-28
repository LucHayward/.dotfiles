#!/usr/bin/env bash
# ==============================================================================
# Set some macOS preferences
# Heavily inspired by https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# and https://github.com/beyarkay/dotfiles/
# ==============================================================================


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



# ================
# Install homebrew
# ================
echo -ne "$BOLD Install homebrew? (y/n): $RESET"
read -p " " install_homebrew
if [[ $install_homebrew == [yY] ]]; then
	echo -e "$RESET$BOLD Installing homebrew$RESET"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo -e "$BOLD Homebrew installation finished$RESET"
fi

# ================
# Install packages
# ================

brew install \
 git \
 exa \
 miniconda \
 pandoc \
 gh

# =============
# Install casks
# =============

brew install --cask \
 whatsapp \
 telegram \
 rectangle \
 transmission \
 vlc \
 macs-fan-control \
 iterm2 \
 jetbrains-toolbox \
 Visual-studio-code \
 mactex-no-gui \
 discord \
 todoist

# =================
# Install Nerdfonts
# https://github.com/ryanoasis/nerd-fonts/discussions/1103
# Nerd Font Mono: Strictly monospaced (programming maybe?)
# Nerd Font: Monospaced but potentially overlapping (terminal maybe?)
# Nerd Font Propo: Proportional (text/writing)
# =================
brew tap homebrew/cask-fonts && brew install --cask  font-jetbrains-mono-nerd-font font-fira-code-nerd-font


# =========================
# Install quicklook plugins
# =========================
brew install --cask \
 qlstephen \
 qlcolorcode


# Install the One Dark theme for iTerm
open "${HOME}/.dotfiles/One Dark whiter.itermcolors"

# Initialise conda
conda init "$(basename "${SHELL}")"

# ==========================
# Symlink Sublim Preferences
# ==========================
ln -s ~/.dotfiles/Preferences.sublime_settings /Users/luchayward/Library/Application Support/Sublime Text/Packages/User/
