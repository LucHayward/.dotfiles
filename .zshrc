# Amazon Q pre block. Keep at the top of this file.
# [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# ========================
# Original .zshrc settings
# ========================
export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short

export AUTO_TITLE_SCREENS="NO"

# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
export AWS_EC2_METADATA_DISABLED=true

# export PROMPT="
# %{$fg[white]%}(%D %*) <%?> [%~] $program %{$fg[default]%}
# %{$fg[cyan]%}%m %#%{$fg[default]%} "

# export RPROMPT=

set-title() {
    echo -e "\e]0;$*\007"
}

ssh() {
    set-title $*;
    /usr/bin/ssh -2 $*;
    set-title $HOST
}

export PATH=$HOME/.toolbox/bin:$PATH

# ================================
# Initialize rbenv
# ================================
eval "$(rbenv init - zsh)"

# =============================
# Zshrc - configuration for zsh
# TODO: explore antigen
# =============================
# zmodload zsh/zprof
source ~/.dotfiles/define_colours.sh

# Enable colours for macOS
export CLICOLOR=1

# Use linux-style colors
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Don't put duplicated lines, or lines starting with a space ' ' into the history
HISTCONTROL=ignoreboth

# Save ZSH_History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history
setopt share_history

# ================
# Expand aliases
# ================
function expand-alias() {
    zle _expand_alias
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias

# ====================================
# Fix move to line start/end Jetbrains
# ====================================
bindkey "[D" beginning-of-line
bindkey "[C" end-of-line

# =======================
# Use eza instead of tree
# =======================
alias tree="eza --tree -la --classify --git --git-ignore --ignore-glob=.git"
# Search for all TODOs / FIXMEs from the current directory
alias gtd="grep -ri --exclude-dir=build --exclude-dir=.git -E \"(TODO|FIXME)\" *"
# List long showing filetypes, all files, and git info
alias ll="eza --long --classify --all --git --time-style=long-iso"
# List just the simple things
alias ls="eza --classify --all"
# Always include colours for grep
alias grep='grep --color=auto'
# Show diskfree with human-readable numerals
alias df='df -h'
# Calculate total disk usage for a folder, in human readable numbers
alias du='du -h -c'

# ===========
# git aliases
# ===========
alias gs="git status"
alias gc="git commit -m "
alias ga="git add"
alias gap="git add -p" # add interactively
alias gd="git dag"
alias gy="git yolo"
alias gp="git push"
alias G="git"

# ==============
# Brazil aliases
# ==============
alias bb=brazil-build
alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use -p'
alias bwscreate='bws create -n'
alias brc=brazil-recursive-cmd
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'

# =============
# Kiro CLI alias
# =============
alias kiro='kiro-cli'

# ====================================================================
#                            Amazon Helpers
# https://docs.mango.ec2.aws.dev/Pawelmas%20Tips/CodeReviews/#crselect
# ====================================================================
# Create a new workspace for a package, and then include that package in the workspace:
# Usage: cws EC2SpacesDocsWebsite
function new-ws() {
  cd ~/workplace/
  brazil ws create --name ${1}
  cd ~/workplace/${1}

  brazil ws use -p ${1}
  wd ${1}
}
alias cws="new-ws"

# ==================
# Convert Gif to mp4
# ==================
gif2vid() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: convert_gif_to_mp4 <input_path> <output_path>"
        return 1
    fi
    local input_path="$1"
    local output_path="$2"
    ffmpeg -loglevel error -i "$input_path" -movflags faststart -pix_fmt yuv420p -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" "$output_path"
}


ssh-ops () {
	export OPSHOST="$(~/workplace/SlamUtils/src/SlamUtils/bin/expand-hostclass --one-host AWS-FOUNDRY-OPS-CORP)"
	ssh -t $OPSHOST "PATH=/apollo/env/FoundryOpsCli/bin:/apollo/env/FoundryOps/bin:/apollo/env/FoundryServiceCopy/bin:$PATH sudo -u awsadmin logbash"
}

alias tc="ssh -A -t dev-dsk-luchay-1b-1434e271.eu-west-1.amazon.com /apollo/env/envImprovement/bin/tmux -u -CC new-session -A -s tc"

alias rsync="rsync -avhP --delete --exclude='.DS_Store'"

# =================================
# Add colours to the less/man pages
# =================================
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'


# =============================================================================
# Super handy: After changing directory, list the contents of that directory
# Note that if there's an absurd number of files in a directory, this will list
# them all which can be annoying if you're often changing in and out of it
# =============================================================================
function cd() {
    builtin cd "$*" && ls
}


# Setup colours and variables for the prompt
# local BG_GREY='236'
# local FG_RED='160'
# local FG_ORANGE='208'
# local FG_YELLOW='226'
# local FG_LIGHTGREY='251'
# local FG_GREY='244'
# local FG_DARKGREY='238'
# local FG_GREEN='46'
# local FG_CYAN='51'
# local FG_TURQUOISE='39'
# local FG_DEEPBLUE='75'
# local NO_BG='234'
# local WHITE='255'
# local FG_RED='196'

# ==========================
# Enable zsh Autosuggestions
# ==========================
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# First look for history items, then look for zsh-completion items
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ===========================
# Fzf options and preferences
# ===========================
source <(fzf --zsh)

# Exclude .unison and .git directories from all fzf commands using fd
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .unison --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .unison --exclude .git'

# Bind the ç character (Alt+C on macOS) to fzf-cd-widget
bindkey 'ç' fzf-cd-widget

# ===============
# Set ZSH options
# ===============
export PATH=/usr/local/bin:$HOME/.local/bin:$PATH
export SSH_KEY_PATH="~/.ssh/rsa_id"
export TERM="xterm-256color"

# ===================================================
# Load completions related things
# For checking the cache only once per day 
# https://htr3n.github.io/2018/07/faster-zsh/ 
# and https://carlosbecker.com/posts/speeding-up-zsh
# ===================================================
if [ ! -d ~/.zsh/zsh-completions ]; then
      git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
fi
fpath=(~/.zsh/zsh-completions/src $fpath)
if [[ "$HOME" == /Users/* ]]; then
    fpath=($(brew --prefix)/share/zsh/site-functions ${fpath})  # For https://code.amazon.com/packages/AmazonZshFunctions/trees/mainline/--#
    source /Users/luchay/.brazil_completion/zsh_completion
fi
autoload -Uz compinit
autoload -U bashcompinit
if [[ "$OSTYPE" == "darwin"* ]]; then
    stat_cmd="/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump"
else
    mod_time=$(/usr/bin/stat --format='%Y' ${ZDOTDIR:-$HOME}/.zcompdump)
    stat_cmd=$(date +'%j' -d @$mod_time)
fi

current_day=$(date +'%j')
if [ "$current_day" != "$stat_cmd" ]; then
    compinit
    bashcompinit
else
    compinit -C
    bashcompinit -C
fi
# eval "$(pandoc --bash-completion)"

# Set up mise for runtime management
eval "$($HOME/.local/bin/mise activate zsh)"
source ~/.local/share/mise/completions.zsh
source $HOME/.brazil_completion/zsh_completion

# ==================
# Completion stylyes
# ==================
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestionsn
zstyle ':completion:*' list-suffixest
zstyle ':completion:*' expand prefix suffix

# Menu completions
setopt AUTO_LIST
setopt AUTO_MENU
zstyle ':completion:*' menu select=3 # at least N menu options allows for arrow key selection

# Case-insensitive globbing
setopt NO_CASE_GLOB 

# Automatic command correction
setopt CORRECT
setopt CORRECT_ALL

# Auto cd
setopt AUTO_CD

# Turn off the annoying beep
setopt NO_LIST_BEEP


# =========================
# Add Syntax Highlighting
# =========================
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# ==============
# Add Go to PATH
# ==============
# export PATH=$PATH:/usr/local/go/bin  # Commented out - using Homebrew Go instead

# =================================
# Set Starship.rs as custom prompt
# =================================
eval "$(starship init zsh)"
eval "$(starship completions zsh)"


# ==========================
# Add NVM to path with compl
# ==========================
export NVM_DIR="$HOME/.nvm"

# Check if NVM is installed by testing the existence of the NVM directory and scripts
if [[ -d "$NVM_DIR" && -s "$NVM_DIR/nvm.sh" && -s "$NVM_DIR/bash_completion" ]]; then
    . "$NVM_DIR/nvm.sh"             # This loads nvm
    . "$NVM_DIR/bash_completion"    # This loads nvm bash_completion
fi

# ================================
# Add cargo to PATH
# ================================
export PATH=$PATH:$HOME/.cargo/bin

# ============================
# Add git-review-tools to PATH
# ============================
export PATH=$PATH:$HOME/Git-review-tools/bin

# ============================
# Unison file sync management
# ============================
unison-load() {
    launchctl load ~/Library/LaunchAgents/local.unison-file-sync.plist
}

unison-unload() {
    launchctl unload ~/Library/LaunchAgents/local.unison-file-sync.plist
}

unison-status() {
    tail -n 20 ~/.unison/unison-launchd.log
}

# Amazon Q post block. Keep at the bottom of this file.
# [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
