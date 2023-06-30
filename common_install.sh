#!/usr/bin/env bash
# ==========================================
# Common installation script
# Runs specific scripts for macOS and ubuntu
# ==========================================

source ~/.dotfiles/define_colours.sh

# Ask for the administrator password upfront
sudo -v

# ======================================
# Symllink to various dotfiles
# ======================================
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global

ln -sf ~/.dotfiles/.zshrc ~/.zshrc

ln -s ~/.dotfiles/.pandoc ~/.pandoc

# ==============================
# Run OS specific install script	
# ==============================
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


# ==================================
# Setup zsh and nice-to-have plugins
# MacOS already has zsh installed
# ==================================
# Change zsh to be the default shell
echo -ne "$BOLD Set zsh to default shell? (y/n): $RESET"
read -p " " set_zsh
if [[ $set_zsh == [yY] ]]; then
    echo -e "$RESET[D] Sudo-ing to make zsh default shell$RESET$RED"
    sudo sh -c "echo $(which zsh) >> /etc/shells" && chsh -s $(which zsh)
    echo -e "$RESET"
fi

echo -ne "$BOLD Install zsh plugins? (y/n): $RESET"
read -p " " set_zsh
if [[ $set_zsh == [yY] ]]; then
    echo -e "$RESET[D] Installing zsh plugins$RESET$RED"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    echo -e "$RESET"
fi