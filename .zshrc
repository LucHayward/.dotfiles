# =============================
# Zshrc - configuration for zsh
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
setopt appendhistory

# ================
# Expand aliases
# ================
function expand-alias() {
    zle _expand_alias
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias

# =======================
# Use exa instead of tree
# =======================
alias tree="exa --tree -lFa --git --git-ignore --ignore-glob=.git"
# Search for all TODOs / FIXMEs from the current directory
alias gtd="grep -ri --exclude-dir=build --exclude-dir=.git -E \"(TODO|FIXME)\" *"
# List long showing filetypes, all files, and git info
alias ll="exa --long --classify --all --git --time-style=long-iso"
# List just the simple things
alias ls="COLUMNS=80 exa --classify --all"
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
local BG_GREY='236'
local FG_RED='160'
local FG_ORANGE='208'
local FG_YELLOW='226'
local FG_LIGHTGREY='251'
local FG_GREY='244'
local FG_DARKGREY='238'
local FG_GREEN='46'
local FG_CYAN='51'
local FG_TURQUOISE='39'
local FG_DEEPBLUE='75'
local NO_BG='234'
local WHITE='255'
local FG_RED='196'


# ==========================
# Enable zsh Autosuggestions
# ==========================
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# First look for history items, then look for zsh-completion items
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ===============
# Set ZSH options
# ===============

export PATH=/usr/local/bin:$HOME/.local/bin:$PATH
export SSH_KEY_PATH="~/.ssh/rsa_id"
export TERM="xterm-256color"


# ===============================
# Load completions related things
# ===============================
autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit

eval "$(pandoc --bash-completion)"

# ==================
# Completion stylyes
# ==================
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions n
zstyle ':completion:*' list-suffixes t
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

# 
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/luc/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/luc/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/luc/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/luc/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ================================
# Add cargo to PATH
# ================================
export PATH=$PATH:$HOME/.cargo/bin
export MODULAR_HOME="/home/luc/.modular"
export PATH="/home/luc/.modular/pkg/packages.modular.com_mojo/bin:$PATH"


# ==============
# Add Go to PATH
# ==============
export PATH=$PATH:/usr/local/go/bin

# =================================
# Set Starship.rs as custom prompt
# =================================
eval "$(starship init zsh)"

# =========================
# Add Syntax Highlighting
# =========================
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# zprof