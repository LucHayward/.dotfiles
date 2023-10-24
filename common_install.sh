#!/usr/bin/env bash
# ==========================================
# Common installation script
# Runs specific scripts for macOS and ubuntu
# ==========================================

source ~/.dotfiles/define_colours.sh

# Function to ask for confirmation with a description
function ask_confirmation() {
    local description="$1"
    read -p "Do you want to run the following section? (y/n): $description : " choice
    case "$choice" in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

# Ask for the administrator password upfront
sudo -v

# ======================================
# Symllink to various dotfiles and directories
# ======================================
if ask_confirmation "Symmlink various dotfiles"; then
    ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
    ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global

    ln -sf ~/.dotfiles/.zshrc ~/.zshrc
    ln -sf ~/.dotfiles/.pandoc ~/.pandoc

fi

# ==============================
# Run OS specific install script    
# ==============================
if ask_confirmation "Run OS specific install script"; then
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
    echo -e "Running on ${machine}"

    # Check the current operating system and source the appropriate script
    if [[ "${machine}" == "Mac" ]]; then
        source mac_install.sh
    elif [[ "${machine}" == "Linux" ]]; then
        source linux_install.sh
    else
        echo "Operating system is not macOS or Linux. Skipping installation."
    fi
fi

# ==================================
# Setup zsh and nice-to-have plugins
# MacOS already has zsh installed
# ==================================
if ask_confirmation "Set zsh to default shell"; then
    echo -e "$RESET[D] Sudo-ing to make zsh default shell$RESET$RED"
    sudo sh -c "echo $(which zsh) >> /etc/shells" && chsh -s $(which zsh)
    echo -e "$RESET"
fi

if ask_confirmation "Install zsh plugins"; then
    echo -e "$RESET[D] Installing zsh plugins$RESET$RED"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    echo -e "$RESET"
fi
