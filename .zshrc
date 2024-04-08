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

# =======================
# Use eza instead of tree
# =======================
alias tree="eza --tree -lFa --git --git-ignore --ignore-glob=.git"
# Search for all TODOs / FIXMEs from the current directory
alias gtd="grep -ri --exclude-dir=build --exclude-dir=.git -E \"(TODO|FIXME)\" *"
# List long showing filetypes, all files, and git info
alias ll="eza --long --classify --all --git --time-style=long-iso"
# List just the simple things
alias ls="COLUMNS=80 eza --classify --all"
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


# # =============================================================================
# # Calculate a short-form of pwd, where instead of /User/boyd/Documents you have
# # /U/b/Documents in order to save space
# # Really not needed now with starship
# # =============================================================================
# function short_pwd {
#     directories=(${(s:/:)PWD})

#     shortened_path=""
#     for ((i = 0; i <= ${#directories[@]}; ++i)); do
#         directory=${directories[$i]}
#         if [ $i = ${#directories} ]; then
#             # The final directory in the path should be left as-is, unshortened
#             shortened_path+="%F{$FG_LIGHTGREY}${directory}%F{$FG_GREY}"
#         else
#             # Set the shortened path to be just the first character of the
#             # current directory
#             shortened_path+="${directory:0:1}/"
#         fi
#     done
#     echo "${shortened_path}"
# }

# https://github.com/beyarkay/dotfiles/blob/8b12553925d959d2ec6759564323595e5aeb182e/.zshrc#L138
# precmd()

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
# https://github.com/beyarkay/dotfiles/blob/8b12553925d959d2ec6759564323595e5aeb182e/.zshrc#L305
# https://github.com/beyarkay/dotfiles/blob/8b12553925d959d2ec6759564323595e5aeb182e/.zshrc#L336

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
autoload -Uz compinit
autoload -U bashcompinit
autoload -Uz compinit
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
eval "$(pandoc --bash-completion)"

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

# ================================
# Add cargo to PATH
# ================================
export PATH=$HOME/.cargo/bin:$PATH
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
eval "$(starship completions zsh)"

# =========================
# Add Syntax Highlighting
# =========================
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

# =======================
# Add kubectl completions
# =======================
source <(kubectl completion zsh)

# zprof# 