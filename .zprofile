# Kiro CLI pre block. Keep at the top of this file.
# [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

# Everything here is macOS-specific (Homebrew, JetBrains Toolbox, Obsidian).
# It's a no-op on Linux devdesks, which share this file via the dotfiles symlinks.
if [[ "$OSTYPE" == "darwin"* ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# Added by Toolbox App
	export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

	# Added by Obsidian
	export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi

# Kiro CLI post block. Keep at the bottom of this file.
# [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
