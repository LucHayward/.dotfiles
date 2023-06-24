#!/usr/bin/env bash
# ==============================================================================
# Set some linux preferences
# Heavily inspired by https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# and https://github.com/beyarkay/dotfiles/
# ==============================================================================

# =================
# First install ZSH
# =================
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



# ================
# Install packages
# ================

# Update package lists
sudo apt update

# Install packages using apt
sudo apt install -y \
  git \
  exa

# Install Miniconda (replace URL with the latest version)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
rm miniconda.sh

# Add Conda to PATH (optional, remove if not needed)
echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc

# Install Pandoc
sudo apt install -y pandoc

# Install additional software using Snap (similar to Homebrew casks)
sudo snap install --classic \
  iterm2 \
  code

# Install Jetbrains Toolbox (replace URL with the latest version)
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz -O jetbrains-toolbox.tar.gz
tar -xzf jetbrains-toolbox.tar.gz
rm jetbrains-toolbox.tar.gz
./jetbrains-toolbox-*/jetbrains-toolbox

# Install LaTeX (TeX Live)
sudo apt install -y texlive


