#!/bin/zsh
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
echo "Enter SUDO password:"
sudo -v

# ==========================================
# Pre-flight
# ==========================================
echo ""
echo "========================================"
echo "	DOTFILES INSTALLER"
echo "========================================"
echo ""
echo "This script will prompt for each section. Use -y to skip prompts."
echo "Some steps require YubiKey interaction (mwinit) or a reboot (Brazil CLI)."
echo ""

# ======================================
# Symlink various dotfiles and directories
# ======================================
if ask_confirmation "Symlink various dotfiles"; then
	ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
	ln -sf ~/.dotfiles/.gitignore_global ~/.gitignore_global


	ln -sf ~/.dotfiles/.zshrc ~/.zshrc
	ln -sf ~/.dotfiles/.zshenv ~/.zshenv
	ln -sf ~/.dotfiles/.zprofile ~/.zprofile
	ln -sfn ~/.dotfiles/.pandoc ~/.pandoc
	mkdir -p ~/.config
	ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
	ln -sf ~/.dotfiles/cship.toml ~/.config/cship.toml
	mkdir -p ~/.config/mise
	ln -sf ~/.dotfiles/mise/config.toml ~/.config/mise/config.toml
	mise trust ~/.dotfiles/mise/config.toml 2>/dev/null
	ln -sf ~/.dotfiles/.zlogin ~/.zlogin
	mkdir -p ~/.ssh
	ln -sf ~/.dotfiles/ssh/config ~/.ssh/config
	ln -sf ~/.dotfiles/.vimrc ~/.vimrc
	ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf
	mkdir -p ~/.config/bat ~/.config/git ~/.aws
	ln -sf ~/.dotfiles/config/bat/config ~/.config/bat/config
	ln -sf ~/.dotfiles/config/git/excludes ~/.config/git/excludes
	ln -sf ~/.dotfiles/aws/config ~/.aws/config

	# Claude Code config
	# Link the whole directory so atomic settings writes stay in dotfiles.
	# This runs before Toolbox installs claude-code, so a fresh machine
	# writes straight through the link; an existing ~/.claude is moved aside.
	claude_config_dir="$HOME/.claude"
	claude_repo_dir="$HOME/.dotfiles/.claude"
	if [[ ( -e "$claude_config_dir" || -L "$claude_config_dir" ) &&
		( ! -L "$claude_config_dir" || "${claude_config_dir:A}" != "${claude_repo_dir:A}" ) ]]; then
		claude_backup="${claude_config_dir}.dotfiles-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
		mv "$claude_config_dir" "$claude_backup" || exit 1
		echo "	Previous Claude config saved to $claude_backup"
	fi
	ln -sfn "$claude_repo_dir" "$claude_config_dir" || exit 1

	# Kiro CLI config
	mkdir -p ~/.kiro/settings
	ln -sf ~/.dotfiles/.kiro/settings/cli.json ~/.kiro/settings/cli.json

	# Codex config
	mkdir -p ~/.codex/rules ~/.codex/skills/web-search
	ln -sf ~/.dotfiles/.codex/AGENTS.md ~/.codex/AGENTS.md
	ln -sf ~/.dotfiles/.codex/config.toml ~/.codex/config.toml
	ln -sf ~/.dotfiles/.codex/rules/default.rules ~/.codex/rules/default.rules
	ln -sf ~/.dotfiles/.codex/skills/web-search/SKILL.md ~/.codex/skills/web-search/SKILL.md

	# Amazon Codex wrapper config (separate from the native ~/.codex config).
	# Link the directory so post-install's atomic config writes stay in dotfiles.
	codex_wrapper_config_dir=""
	case "$(uname -s)" in
		Darwin) codex_wrapper_config_dir="$HOME/Library/Application Support/com.amazon.Amzn-OpenAICodex" ;;
		Linux) codex_wrapper_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/amzn-openaicodex" ;;
	esac
	if [[ -n "$codex_wrapper_config_dir" ]]; then
		codex_wrapper_repo_dir="$HOME/.dotfiles/config/amzn-openaicodex"
		mkdir -p "${codex_wrapper_config_dir:h}" || exit 1
		if [[ ( -e "$codex_wrapper_config_dir" || -L "$codex_wrapper_config_dir" ) &&
			( ! -L "$codex_wrapper_config_dir" || "${codex_wrapper_config_dir:A}" != "${codex_wrapper_repo_dir:A}" ) ]]; then
			codex_wrapper_backup="${codex_wrapper_config_dir}.dotfiles-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
			mv "$codex_wrapper_config_dir" "$codex_wrapper_backup" || exit 1
			echo "	Previous Codex wrapper config saved to $codex_wrapper_backup"
		fi
		ln -sfn "$codex_wrapper_repo_dir" "$codex_wrapper_config_dir" || exit 1
	fi

	# Unison sync profiles
	mkdir -p ~/.unison
	ln -sf ~/.dotfiles/unison/default.prf ~/.unison/default.prf
	ln -sf ~/.dotfiles/unison/obsidian.prf ~/.unison/obsidian.prf

	# Unison LaunchAgents (macOS only)
	if [[ "$(uname -s)" == "Darwin" ]]; then
		mkdir -p ~/Library/LaunchAgents
		ln -sf ~/.dotfiles/unison/local.unison-file-sync.plist ~/Library/LaunchAgents/local.unison-file-sync.plist
		ln -sf ~/.dotfiles/unison/local.unison-obsidian-sync.plist ~/Library/LaunchAgents/local.unison-obsidian-sync.plist

		# Obsidian vault registry (points Obsidian at ~/ObsidianVault)
		mkdir -p ~/Library/Application\ Support/obsidian
		ln -sf ~/.dotfiles/obsidian.json ~/Library/Application\ Support/obsidian/obsidian.json
	fi
fi

# ==============================
# Run OS specific install script	
# ==============================
if ask_confirmation "Run OS specific install script"; then
	unameOut="$(uname -s)"
	case "${unameOut}" in
		Linux*)		machine=Linux;;
		Darwin*)	machine=Mac;;
		*)			machine="UNKNOWN:${unameOut}"
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

# ==============================
# Install cship on both platforms, after Rust setup
# ==============================
if ask_confirmation "Install cship using Cargo (Claude Code statusline)"; then
	"${CARGO_HOME:-$HOME/.cargo}/bin/cargo" install --locked cship || exit 1
	echo 'Claude statusLine: {"type": "command", "command": "bash ~/.dotfiles/.claude/statusline.sh", "refreshInterval": 300}'
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


# =================
# Install zsh-bench
# According to the author any value below the following is imperceptible:
# | latency (ms)		  |		 |
# |-----------------------|-----:|
# | **first prompt lag**  |	  50 |
# | **first command lag** |	 150 |
# | **command lag**		  |	  10 |
# | **input lag**		  |	  20 |
# =================
if ask_confirmation "Install and run zsh-bench"; then
	[[ -d ~/zsh-bench ]] || git clone https://github.com/romkatv/zsh-bench ~/zsh-bench
	~/zsh-bench/zsh-bench
fi
