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
  code \
  sublime-text

# Install Jetbrains Toolbox (replace URL with the latest version)
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz -O jetbrains-toolbox.tar.gz
tar -xzf jetbrains-toolbox.tar.gz
rm jetbrains-toolbox.tar.gz
./jetbrains-toolbox-*/jetbrains-toolbox

# Install LaTeX (TeX Live)
sudo apt install -y texlive

# Install Github CLI
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

