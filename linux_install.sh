#!/usr/bin/env zsh
# ==============================================================================
# Set some Linux preferences
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

# Detect supported package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
else
    echo "Unsupported package manager. This script currently supports apt and pacman."
    exit 1
fi

function update_system() {
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove && sudo apt autoclean
    else
        sudo pacman -Syu --noconfirm
    fi
}

function install_packages() {
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt install -y "$@"
    else
        sudo pacman -S --noconfirm --needed "$@"
    fi
}

# =================
# First install ZSH
# =================

if ask_confirmation "Install Zsh and set it as the default shell"; then
    # Check if Zsh is already installed
    if command -v zsh &>/dev/null; then
        echo "Zsh is already installed."
    else
        # Install Zsh
        update_system
        install_packages zsh

        # Set Zsh as the default shell
        chsh -s $(command -v zsh)

        # Verify installation
        if [ $? -eq 0 ]; then
            echo "Zsh has been successfully installed."
        else
            echo "Failed to install Zsh."
        fi
    fi
fi

# ================
# Install packages
# ================

if ask_confirmation "Update package lists and install essential packages"; then
    update_system

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_packages \
          git \
          gnome-tweaks \
          build-essential
    else
        install_packages \
          git \
          gnome-tweaks \
          base-devel
    fi
fi

if command -v rustup > /dev/null; then
    echo "Rustup already installed."
else
    if ask_confirmation "Install rustup"; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source "$HOME/.cargo/env"
    fi
fi


if ask_confirmation "Install Miniconda and configure it"; then
    # Install Miniconda (replace URL with the latest version)
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh
    ~/miniconda3/bin/conda init zsh
fi

if ask_confirmation "Install Pandoc"; then
    # Install Pandoc
    install_packages pandoc
fi

if ask_confirmation "Install additional software using Snap"; then
    # Install additional software using Snap (similar to Homebrew casks)
    sudo snap install --classic code
    sudo snap install --classic sublime-text
fi
# =============================
# Symlink sublime text settings
# =============================
mkdir -p ~/.config/sublime-text/Packages/User
ln -sf ~/.dotfiles/Preferences.sublime-settings ~/.config/sublime-text/Packages/User/


if ask_confirmation "Install JetBrains Toolbox"; then
    # Install JetBrains Toolbox (replace URL with the latest version)
    wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz -O jetbrains-toolbox.tar.gz
    tar -xzf jetbrains-toolbox.tar.gz
    rm jetbrains-toolbox.tar.gz
    ./jetbrains-toolbox-*/jetbrains-toolbox
fi

if ask_confirmation "Install LaTeX (TeX Live)"; then
    # Install LaTeX (TeX Live)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_packages texlive
    else
        install_packages texlive-most
    fi
fi

if ask_confirmation "Install GitHub CLI"; then
    # Install Github CLI
    type -p curl >/dev/null || install_packages curl

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    else
        install_packages github-cli
    fi
fi

# ==========================
# Authenticate GitHub CLI
# ==========================
if command -v gh &>/dev/null; then
    if ask_confirmation "Authenticate GitHub CLI (gh auth login)"; then
        gh auth login
    fi
fi

# ================
# Install Starship.rs
# ================
if ask_confirmation "Install Starship.rs prompt"; then
    curl -fsSL https://starship.rs/install.sh | sh
fi

# ========================
# Install ccusage and cship (Claude Code statusline)
# ========================
if ask_confirmation "Install ccusage + cship (Claude Code usage & statusline)"; then
    npm install -g ccusage
    cargo install cship
    echo "✓ cship configured via .claude/settings.json statusLine (command: cship)"
fi
