#!/usr/bin/env bash
# ==============================================================================
# Set some Linux preferences
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

# =================
# First install ZSH
# =================

if ask_confirmation "Install Zsh and set it as the default shell"; then
    # Check if Zsh is already installed
    if command -v zsh &>/dev/null; then
        echo "Zsh is already installed."
    else
        # Install Zsh
        sudo apt update
        sudo apt install -y zsh

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
    # Update package lists
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove && sudo apt autoclean

    # Install packages using apt
    sudo apt install -y \
      git \
      gnome-tweaks
fi

if ask_confirmation "Install rustup"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if ask_confirmation "Install 'exa' using Cargo"; then
    # exa doesn't install correctly on Ubuntu
    # sudo apt install -y cargo
    cargo install exa
    echo '# ================================
    # Add cargo to PATH
    # ================================
    export PATH=$PATH:$HOME/.cargo/bin' >> .zshrc
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
    sudo apt install -y pandoc
fi

if ask_confirmation "Install additional software using Snap"; then
    # Install additional software using Snap (similar to Homebrew casks)
    sudo snap install --classic \
      code-insiders \
      sublime-text
fi

if ask_confirmation "Install JetBrains Toolbox"; then
    # Install JetBrains Toolbox (replace URL with the latest version)
    wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz -O jetbrains-toolbox.tar.gz
    tar -xzf jetbrains-toolbox.tar.gz
    rm jetbrains-toolbox.tar.gz
    ./jetbrains-toolbox-*/jetbrains-toolbox
fi

if ask_confirmation "Install LaTeX (TeX Live)"; then
    # Install LaTeX (TeX Live)
    sudo apt install -y texlive
fi

if ask_confirmation "Install GitHub CLI"; then
    # Install Github CLI
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
fi
