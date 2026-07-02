#!/usr/bin/env zsh
# ==========================================
# Common installation script
# Runs specific scripts for macOS and ubuntu
# ==========================================

source ~/.dotfiles/define_colours.sh

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

# Ask for the administrator password upfront
sudo -v

# ==========================================
# Pre-flight
# ==========================================
echo ""
echo "========================================"
echo "  DOTFILES INSTALLER"
echo "========================================"
echo ""
echo "This script will prompt for each section. Use -y to skip prompts."
echo ""

# ======================================
# Symlink various dotfiles and directories
# ======================================
if ask_confirmation "Symlink various dotfiles"; then
    ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
    ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global
    ln -sf ~/.dotfiles/.condarc ~/.condarc

    ln -sf ~/.dotfiles/.zshrc ~/.zshrc
    ln -sf ~/.dotfiles/.zprofile ~/.zprofile
    ln -sfn ~/.dotfiles/.pandoc ~/.pandoc
    mkdir -p ~/.config
    ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
    ln -sf ~/.dotfiles/cship.toml ~/.config/cship.toml
    mkdir -p ~/.config/mise
    ln -sf ~/.dotfiles/mise/config.toml ~/.config/mise/config.toml
    mise trust ~/.dotfiles/mise/config.toml 2>/dev/null
    ln -sf ~/.dotfiles/.zlogin ~/.zlogin
    ln -sf ~/.dotfiles/.vimrc ~/.vimrc
    mkdir -p ~/.config/bat ~/.config/git
    ln -sf ~/.dotfiles/config/bat/config ~/.config/bat/config
    ln -sf ~/.dotfiles/config/git/excludes ~/.config/git/excludes
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
# Setup zsh (Linux only, macOS already uses zsh)
# ==================================
if [[ "$(uname -s)" != "Darwin" ]]; then
    if ask_confirmation "Set zsh to default shell"; then
        ZSH_PATH="$(which zsh)"
        if ! grep -q "$ZSH_PATH" /etc/shells; then
            echo "$ZSH_PATH" | sudo tee -a /etc/shells
        fi
        chsh -s "$ZSH_PATH"
    fi
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
    [[ -d ~/zsh-bench ]] || git clone https://github.com/romkatv/zsh-bench ~/zsh-bench
    ~/zsh-bench/zsh-bench
fi

# ================
# Install cship (Claude Code statusline)
# Requires cargo (install rustup first via OS-specific script)
# ================
if ask_confirmation "Install eza and cship via Cargo"; then
    cargo install eza
    cargo install cship
    cargo install uv
    cargo install ast-grep
fi
