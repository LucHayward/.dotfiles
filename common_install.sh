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
    ln -s ~/.dotfiles/.condarc ~/.condarc

    ln -sf ~/.dotfiles/.zshrc ~/.zshrc
    ln -sf ~/.dotfiles/.pandoc ~/.pandoc
    mkdir -p ~/.config
    ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
    ln -sf ~/.dotfiles/.zlogin ~/.zlogin
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
# Setup zsh
# MacOS already has zsh installed
# ==================================
if ask_confirmation "Set zsh to default shell"; then
    echo -e "$RESET[D] Sudo-ing to make zsh default shell$RESET$RED"
    sudo sh -c "echo $(which zsh) >> /etc/shells" && chsh -s $(which zsh)
    echo -e "$RESET"
fi


# =====================
# Setup git credentials
# =====================
if ask_confirmation "Setup git credentials using gh"; then
    gh auth login
fi

# =================
# Install zsh-bench
# According to the author any value below the following is imperceptible:
# | latency (ms)          |      |
# |-----------------------|-----:|
# | **first prompt lag**  |   50 |
# | **first command lag** |  150 |
# | **command lag**       |   10 |
# | **input lag**         |   20 |
# =================
if ask_confirmation "Install and run zsh-bench"; then
    git clone https://github.com/romkatv/zsh-bench ~/zsh-bench
    ~/zsh-bench/zsh-bench
fi


