# zmodload zsh/zprof
# Kiro CLI pre block. Keep at the top of this file.
# if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     [[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh"
# else
#     [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
# fi

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
# Initialize rbenv (lazy-loaded)
# ================================
if command -v rbenv &> /dev/null; then
    rbenv() {
        unfunction rbenv
        eval "$(command rbenv init - zsh)"
        rbenv "$@"
    }
fi

# =============================
# Zshrc - configuration for zsh
# TODO: explore antigen
# =============================
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
alias bbf='brazil-build format'
alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias bte='brazil-test-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use -p'
alias bwscreate='bws create -n'
alias brc=brazil-recursive-cmd
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'

alias cr='cr --destination-branch mainline --parent mainline'

# ==============
# Unison aliases
# ==============
alias unison-status='tail -f ~/.unison/unison-launchd.log ~/.unison/unison-obsidian.log'
alias unison-load='launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.unison-file-sync.plist; launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.unison-obsidian-sync.plist'
alias unison-unload='launchctl bootout gui/$(id -u)/local.unison-file-sync; launchctl bootout gui/$(id -u)/local.unison-obsidian-sync'

alias ec2-ssh=/apollo/env/EC2SSHWrapper/bin/ec2-ssh

# =============
# Kiro CLI alias
# =============
alias kiro='kiro-cli'

# =================
# Claude Code alias
# =================
alias clauded='claude --dangerously-skip-permissions'

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

 ssh-ops() {
    sshenv FoundryOps/CORP --auto --ssh "ssh -t" "sudo -u awsadmin env PATH=/apollo/env/FoundryOpsCli/bin:/apollo/env/FoundryOps/bin:/apollo/env/FoundryServiceCopy/bin:\$PATH bash -c 'mkdir -p /local/tmp/\$SUDO_USER && chmod g+w /local/tmp/\$SUDO_USER 2>/dev/null; cd /local/tmp/\$SUDO_USER && exec logbash'"
}

 ssh-ops-ro() {
    sshenv FoundryOps/CORP --auto --ssh "ssh -t" "sudo -u foundry-ops-ro env PATH=/apollo/env/FoundryOpsCli/bin:/apollo/env/FoundryOps/bin:/apollo/env/FoundryServiceCopy/bin:\$PATH bash -c 'mkdir -p /local/tmp/\$SUDO_USER && chmod g+w /local/tmp/\$SUDO_USER 2>/dev/null; cd /local/tmp/\$SUDO_USER && exec logbash'"
}

alias tc="autossh -M 0 -A -t clouddesk /apollo/env/envImprovement/bin/tmux -u -CC new-session -AD -s tc"
alias tfix="ssh clouddesk /apollo/env/envImprovement/bin/tmux detach-client -a -s tc"

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
# https://github.com/beyarkay/dotfiles/blob/main/.zshrc#L305C1-L305C30
# ===========================
# Add fzf to PATH on Linux (Homebrew handles this on macOS)
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -d "$HOME/.fzf/bin" ]]; then
    export PATH="$HOME/.fzf/bin:$PATH"
fi

if command -v fzf &> /dev/null; then
    source <(fzf --zsh)

    # Exclude .unison, .git, and build directories from all fzf commands using fd.
    # --max-depth 6 keeps deep monorepo trees (e.g. ~/workplace with dozens of
    # Brazil packages) tractable: without it fd walks ~17k files per invocation.
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --max-depth 6 --exclude .unison --exclude .git --exclude build'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # Alt+C (cd): breadth-first ordering. fd emits in nondeterministic parallel
    # order, so the pre-typing view is random; sorting by path depth (slash count)
    # surfaces shallow dirs first. fzf re-ranks by match score once you type.
    # No --hidden here: we rarely cd into dotfolders, and it drops macOS system
    # dirs (.Trashes, .fseventsd) from the menu.
    export FZF_ALT_C_COMMAND='fd --type d --max-depth 6 --exclude .unison --exclude .git --exclude build | awk -F/ "{print NF-1\"\t\"\$0}" | sort -n -k1,1 -s | cut -f2-'

    # Bind the ç character (Alt+C on macOS) to fzf-cd-widget
    bindkey 'ç' fzf-cd-widget
fi

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
    fpath=(${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions ${fpath})  # For https://code.amazon.com/packages/AmazonZshFunctions/trees/mainline/--#
    if [[ -f $HOME/.brazil_completion/zsh_completion ]]; then
        source $HOME/.brazil_completion/zsh_completion
    else
        echo "⚠ Brazil completions not found. Run: brazil setup completion" >&2
    fi
fi
autoload -Uz compinit
autoload -U bashcompinit
if [[ ! -f "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then
    stat_cmd=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    stat_cmd=$(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump)
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

# Enable autocompletion for mechanic.
[ -f "$HOME/.local/share/mechanic/complete.zsh" ] && source "$HOME/.local/share/mechanic/complete.zsh"

# Cache the output of a slow `eval "$(cmd ...)"` to a file and source it,
# regenerating only when the underlying binary is newer than the cache.
# Usage: cached_eval <cache-name> <binary> <full command...>
cached_eval() {
  local name="$1" bin="$2"; shift 2
  command -v "$bin" &>/dev/null || return 0
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init"
  local cache="$cache_dir/$name.zsh"
  local bin_path=${commands[$bin]}
  # Regenerate if cache is missing/empty or older than the resolved binary.
  if [[ ! -s "$cache" || "$bin_path" -nt "$cache" ]]; then
    mkdir -p "$cache_dir"
    "$@" > "$cache" 2>/dev/null
  fi
  source "$cache"
}

# Like cached_eval, but defers sourcing until the command is first tab-completed.
# The heavy completion script (uv's is ~550k) never loads in shells where you
# don't complete that command. Usage: lazy_cached_eval <name> <binary> <cmd...>
# zsh functions don't close over locals, so the deferred command is stashed in
# a global keyed by name and read back when completion first fires.
typeset -gA _LAZY_EVAL_CMDS
_lazy_eval_load() {
  local name="$1"; shift
  unfunction "_lazy_complete_${name}"
  local cmd=("${(z)_LAZY_EVAL_CMDS[$name]}")
  cached_eval "$name" "${cmd[@]}"
  _normal  # re-trigger completion now that the real completer is installed
}
lazy_cached_eval() {
  local name="$1" bin="$2"; shift 1
  command -v "$bin" &>/dev/null || return 0
  _LAZY_EVAL_CMDS[$name]="$*"          # bin + full command, e.g. "uv uv generate-shell-completion zsh"
  functions[_lazy_complete_${name}]="_lazy_eval_load ${name}"
  compdef "_lazy_complete_${name}" "$bin"
}

# Set up mise for runtime management (cached; see cached_eval above)
cached_eval mise mise mise activate zsh

# ==================
# Add uv completions (lazy: loaded on first `uv`/`uvx` tab-completion)
# ==================
lazy_cached_eval uv uv uv generate-shell-completion zsh
lazy_cached_eval uvx uvx uvx --generate-shell-completion zsh

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
CORRECT_IGNORE_FILE='.{git,settings}'

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



# ==============
# Add Go to PATH
# ==============
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH=$PATH:$HOME/go/bin
fi
# export PATH=$PATH:/usr/local/go/bin  # Commented out - using Homebrew Go instead

# =================================
# Set Starship.rs as custom prompt
# =================================
eval "$(starship init zsh)"
eval "$(starship completions zsh)"


# ==========================
# NVM (lazy-loaded)
# ==========================
export NVM_DIR="$HOME/.nvm"

_load_nvm() {
    unfunction nvm node npm npx 2>/dev/null
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }

# ================================
# Add cargo to PATH
# ================================
export PATH=$PATH:$HOME/.cargo/bin

# ============================
# Use GNU sed over BSD sed
# ============================
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# ============================
# Use GNU grep over BSD grep
# ============================
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# ============================
# Add git-review-tools to PATH
# ============================
export PATH=$PATH:$HOME/Git-review-tools/bin

# =========
# NVM setup (handled above via lazy-load)
# =========


rm-ssh-key () {
    if [ -z "$1" ]; then
        echo "Usage: remove-ssh-key <hostname>"
        return 1
    fi
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1"
}

update-all() {
    echo "\n📦 System packages"
    echo "──────────────────"
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        brew update && brew upgrade && brew cleanup
    else
        bash "$HOME/.claude/hooks/peon-ping/peon.sh" update
    fi

    echo "\n🧰 Toolbox"
    echo "──────────"
    toolbox update

    echo "\n🛠  Mise"
    echo "────────"
    mise upgrade

    echo "\n🤖 AIM"
    echo "───────"
    aim agents update
    aim mcp update
    aim skills update

    echo "\n🧹 Stripping 'Assisted by AI' from AGENTS.md files..."
    for f in ~/.aim/packages/*/eventId-*/context/*/AGENTS.md; do
        [ -f "$f" ] && sed -i '/🤖 Assisted by AI/d' "$f"
    done

    echo "\n🔀 De-duping bundled builder-mcp from AIM plugins..."
    # Every AIM plugin vendors its own scoped builder-mcp, which Claude Code
    # can't dedupe (each is namespaced plugin_<name>_builder-mcp). We keep the
    # single standalone builder-mcp in ~/.claude.json and strip the key from
    # each plugin's .mcp.json. Only the builder-mcp key is removed; co-located
    # servers (cr-guide, pippin, spec-studio, ...) are left intact.
    for f in ~/.aim/cc-plugins/*/.mcp.json; do
        [ -f "$f" ] || continue
        python3 - "$f" <<'PY'
import json, sys
p = sys.argv[1]
with open(p) as fh:
    d = json.load(fh)
servers = d.get("mcpServers", {})
if "builder-mcp" in servers:
    del servers["builder-mcp"]
    with open(p, "w") as fh:
        json.dump(d, fh, indent=2)
        fh.write("\n")
    print(f"  stripped builder-mcp from {p.split('/cc-plugins/')[-1]}")
PY
    done

    echo "\n✅ All done!"
}


# Added by AIM CLI
export PATH="$HOME/.aim/mcp-servers:$PATH"

# Peon-ping relay reminder (mac only — linux checks the reverse direction)
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
  if command -v peon &>/dev/null && ! peon relay --status &>/dev/null; then
    echo "⚠️  peon relay is not running. Start it with:"
    echo "  peon relay --daemon"
  fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # =====================
    # Add SlamUtils to PATH
    # =====================
    export PATH=$PATH:$HOME/workplace/SlamUtils/src/SlamUtils/bin

    # export PYTHONPATH=$PYTHONPATH:/home/luchay/.local/share/mise/installs/python/3.12.3/lib/python3.12/site-packages
    export PYTHONPATH=$PYTHONPATH:/workplace/luchay/ProfileDumper/src/Kmoroe_Isengard_Profile_Dumper/BotoCoreAmazon

    # Enable autocompletion for mechanic.
    [ -f "$HOME/.local/share/mechanic/complete.zsh" ] && source "$HOME/.local/share/mechanic/complete.zsh"

    export PATH=/apollo/env/ApolloCommandLine/bin:/apollo/env/envImprovement/bin:$PATH


    # peon-ping quick controls (not in PATH on Linux, unlike Homebrew on Mac)
    alias peon="bash $HOME/.claude/hooks/peon-ping/peon.sh"
    [ -f "$HOME/.claude/hooks/peon-ping/completions.bash" ] && source "$HOME/.claude/hooks/peon-ping/completions.bash"

    # Kiro CLI post block. Keep at the bottom of this file.
    # [[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh"
else
    # Kiro CLI post block. Keep at the bottom of this file.
    # [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
fi
# zprof

# Added by AIM CLI
export PATH="/local/home/luchay/.aim/mcp-servers:$PATH"

[[ -f "$HOME/.brazil_completion/zsh_completion" ]] && source "$HOME/.brazil_completion/zsh_completion"
#export USE_BUILDER_ACCOUNT=1
