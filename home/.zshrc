# If you come from bash you might have to change your $PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Consolidated PATH setup
export BUN_INSTALL="$HOME/.bun"
typeset -U path PATH
path=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
    "$HOME/.local/bin"
    "$HOME/.spicetify"
    "$HOME/.opencode/bin"
    "$HOME/go/bin"
    "$BUN_INSTALL/bin"
    $path
)

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Default value
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

fpath=("$HOME/.zfunctions" $fpath)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/vitaliy/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/vitaliy/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/vitaliy/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/vitaliy/google-cloud-sdk/completion.zsh.inc'; fi
# gitignore.io CLI tool integration
function gi() {
    if (( $# == 0 )); then
        print "usage: gi python,node,macos"
        return 1
    fi

    curl -fsSL "https://www.toptal.com/developers/gitignore/api/${(j:,:)@}"
    print
}


# Add MYVIMRC variable to env
export MYVIMRC=$HOME/.config/nvim/init.lua

# Add alias to quickly edit ghostty config file
alias gc="nvim $HOME/.config/ghostty/config"

# Add shortcut for faster venv activation for Python
# 'ave' stands for 'activate virtual environment'
function ave() {
    local activate_script="$PWD/.venv/bin/activate"

    if [[ ! -f "$activate_script" ]]; then
        print "No virtual environment found at $activate_script"
        return 1
    fi

    print "Activating virtual environment"
    source "$activate_script"

    if [[ ":$PYTHONPATH:" != *":$PWD:"* ]]; then
        export PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}$PWD"
    fi
}

function eval_if_cmd() {
    local cmd="$1"
    shift

    (( $+commands[$cmd] )) || return 0
    eval "$("$cmd" "$@")"
}

# Add ngrok completions
eval_if_cmd ngrok completion

# Set up fzf key bindings and fuzzy completion
eval_if_cmd fzf --zsh

# Initialize fnm with automatic version switching on directory changes
eval_if_cmd fnm env --use-on-cd --shell zsh

# Install zoxide (the 'z' command) instead of 'cd'
eval_if_cmd zoxide init --cmd cd zsh

# Set up `eza` instead of `ls`
alias ls='eza'
export EZA_CONFIG_DIR="$HOME/.config/eza"

# Set up `bat` instead of `cat`
alias cat='bat'

# Activate starship prompt
if [[ -o interactive && "${TERM:-}" != "dumb" ]]; then
    eval_if_cmd starship init zsh
fi

# Diary aliases/configuration
export DIARY_HOME=$HOME/Personal/diary
alias diary='cd $DIARY_HOME && nvim $DIARY_HOME/$(date +%Y-%m-%d).md'

# bun completions
[ -s "/Users/vitaliy/.bun/_bun" ] && source "/Users/vitaliy/.bun/_bun"

# Colima
export DOCKER_HOST="unix://${HOME}/.colima/docker.sock"

# Set default editor
export EDITOR="nvim"

# Catppuccin Mocha color scheme
export FZF_DEFAULT_OPTS='
  --color fg:#cdd6f4,bg:#1e1e2e
  --color bg+:#313244,fg+:#cdd6f4
  --color hl:#f38ba8,hl+:#a6e3a1
  --color pointer:#f5e0dc,info:#cba6f7
  --color prompt:#89b4fa,spinner:#f5e0dc,marker:#a6e3a1,header:#89dceb
  --color gutter:#1e1e2e,border:#585b70
  --border
  --height 13'

# Create session work if not exists
alias t='tmux new-session -A -s work'

# Initialize mise for tool shims and automatic version switching
eval_if_cmd mise activate zsh
