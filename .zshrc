# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$PATH:/Users/phill/flutter/bin"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
zstyle ':omz:update' mode disabled  # disable automatic updates
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
mkdir -p ~/.histories
if [[ $TMUX_PANE ]]; then
    tmux_session=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1)
    dir=$(basename $PWD)
    HISTFILE=~/.histories/.tmux_${tmux_session}_${dir}_${TMUX_PANE:1}
fi

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)
#
mkdir -p .histories
if [[ $TMUX_PANE ]]; then
  HISTFILE=$HOME/.histories/.bash_history_tmux_${TMUX_PANE:1}
fi

source $ZSH/oh-my-zsh.sh

export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/home/mfilitov/.local/bin/"


export PATH="$PATH:/home/mfilitov/ydbwork/ydb/ydb/tools/ydbd_slice/bin"
export PATH="$PATH:/home/mfilitov/ydbwork/ydb/ydb/apps/ydb"


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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

alias gotools="cd /home/mfilitov/ydbwork/ydb/ydb/library/yql/tools"
# alias ya='~/ydbwork/ydb/ya'
alias syncrepo="gh repo sync lll-phill-lll/ydb -s ydb-platform/ydb"
alias dqrun="./dqrun -s -p query.sql --enable-spilling --gateways-cfg examples/gateways.conf --fs-cfg examples/fs.conf --bindings-file examples/bindings_tpch.json --udfs-dir ../../udfs/common/"
alias dqrunnospilling="./dqrun -s -p query.sql --gateways-cfg examples/gateways.conf --fs-cfg examples/fs.conf --bindings-file examples/bindings_tpch.json"
alias gdbdqrun="gdb --args ./dqrun -s -p query.sql --enable-spilling  --gateways-cfg examples/gateways.conf --fs-cfg examples/fs.conf --bindings-file examples/bindings_tpch.json --udfs-dir ../../udfs/common/"

alias ya="~/arcadia/ya"
alias ym="ya make -d"

alias k='kubectl'
alias kc='kubectl config get-contexts'
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

alias mem='watch -n1 du -h .'

alias make_slice="/usr/bin/ya make ~/ydbwork/ydb/ydb/tools/ydbd_slice/bin"
alias make_ydb="/usr/bin/ya make ~/ydbwork/ydb/ydb/apps/ydb"
alias make_ydbd="/usr/bin/ya make ~/ydbwork/ydb/ydb/apps/ydbd -j 50" 

if [[ -S "$SSH_AUTH_SOCK" && ! -h "$SSH_AUTH_SOCK" ]]; then
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock;
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock;


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
