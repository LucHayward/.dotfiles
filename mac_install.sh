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
    
    # Add Homebrew to $PATH
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# ================
# Install packages
# ================
if ask_confirmation "Install packages"; then
    brew install \
    git \
    eza \

    pandoc \
    gh \
    bat \
    fzf \
    fd \
    htop
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
    syntax-highlight \
    obsidian \
    sublime-text
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
fi

# ==========================
# Symlink Sublim Preferences
# ==========================
if ask_confirmation "Symlink Sublime Preferences"; then
   mkdir -p "~/Library/Application Support/Sublime Text/Packages/User/"
   ln -s ~/.dotfiles/Preferences.sublime_settings "~/Library/Application Support/Sublime Text/Packages/User/"
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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# ========================
# Install git-review-tools
# ========================
if ask_confirmation "Install git-review-tools from https://w.amazon.com/bin/view/Git-review-tools/"; then
	start_dir=pwd
	cd ~
	git clone ssh://git.amazon.com/pkg/Git-review-tools
	cd $start_dir
fi

# ========================
# SSH, Midway, and WSSH
# ========================
if ask_confirmation "Setup SSH key, mwinit, and WSSH"; then
    echo "--- SSH Key ---"
    if [ ! -f ~/.ssh/id_ecdsa ]; then
        echo "Generating ECDSA SSH key..."
        ssh-keygen -t ecdsa
    else
        echo "SSH key already exists at ~/.ssh/id_ecdsa"
    fi

    echo ""
    echo "--- Midway (mwinit) ---"
    echo "Run: mwinit -f"
    echo "If mwinit is not installed, install it from Self Service (ACME) or: brew install amazon/amazon/mwinit"
    echo ""
    read -p "Press enter once mwinit is working..."

    echo ""
    echo "--- WSSH ---"
    echo "Install WSSH from Self Service (ACME) > search 'WSSH'"
    echo "After install, close and reopen terminal, then verify with: wssh --version"
    echo "Docs: https://w.amazon.com/bin/view/WSSH/setup/macos"
    echo ""
    read -p "Press enter once WSSH is installed..."
fi

# ========================
# Install and configure Unison
# ========================
if ask_confirmation "Install Unison file sync (requires SSH to cloud desktop)"; then
    brew install unison unison-fsmonitor

    # Create the ObsidianVault directory if it doesn't exist
    mkdir -p ~/ObsidianVault

    # Restore Obsidian settings and plugin configs from dotfiles
    cp -r ~/.dotfiles/obsidian-vault-config/ ~/ObsidianVault/.obsidian/
    # Plugins will auto-download their JS on first launch based on manifest.json

    echo ""
    echo "Unison profiles and LaunchAgents have been symlinked from ~/.dotfiles/unison/"
    echo ""
    echo "NOTE: You may need to update the remote host in the .prf files if your cloud desktop hostname has changed."
    echo "  Edit: ~/.unison/default.prf"
    echo "  Edit: ~/.unison/obsidian.prf"
    echo ""
    echo "NOTE: Open Obsidian and point it at ~/ObsidianVault once sync is running."
    echo ""
    read -p "Press enter to load the LaunchAgents (starts sync)..."

    launchctl load ~/Library/LaunchAgents/local.unison-file-sync.plist
    launchctl load ~/Library/LaunchAgents/local.unison-obsidian-sync.plist
fi

# ================================
# Install Builder Toolbox and tools
# ================================
if ask_confirmation "Install Builder Toolbox and Amazon dev tools (requires mwinit first)"; then
    # Bootstrap Builder Toolbox
    curl -X POST \
      --data '{"os":"osx"}' \
      -H "Authorization: $(curl -L --cookie $HOME/.midway/cookie --cookie-jar $HOME/.midway/cookie \
        "https://midway-auth.amazon.com/SSO?client_id=https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev&response_type=id_token&nonce=$RANDOM&redirect_uri=https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev:443")" \
      https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev/v1/bootstrap \
      > ~/toolbox-bootstrap.sh
    bash ~/toolbox-bootstrap.sh
    rm ~/toolbox-bootstrap.sh
    source ~/.$(basename "$SHELL")rc

    # Install core tools
    toolbox install aim kiro-cli builder-mcp

    # AxE installs most common tools (brazilcli, cr, ada, etc.)
    toolbox install axe
    axe init builder-tools

    # AIM agents and MCP servers
    aim agents install AIPowerUserCapabilities
fi