# Initialize environment
export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export EDITOR="nvim"

# Powerlevel10k theme configuration
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Oh My Zsh plugins
plugins=(
    copypath
    dircycle
    extract
    frontend-search
    git
    git-auto-fetch
    git-flow-completion
    gitfast
    git-prompt
    ionic
    pre-commit
    safe-paste
    web-search
    zsh-completions
    zsh-history-substring-search
)

# Display banner
TNAME="Tmx-3.0"
cols=$(tput cols)
bash ~/.banner.sh ${cols} ${TNAME}

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Powerlevel10k instant prompt (keep near top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k theme
source $ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# External plugins (Termux system-wide installation)
source $PREFIX/etc/.plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PREFIX/etc/.plugin/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases
alias pkg='nala'
#alias apt='nala'
alias g='git clone'
alias t='termux-open'
alias ai='nala install'
alias py='python'
alias py2='python2'
alias py3='python3'
alias m='vi'
alias ls='logo-ls'
alias lsa='logo-ls -A'
alias lsal='logo-ls -R -A'
alias lsall='logo-ls -r -A'
alias r='termux-reload-settings'
alias storage='termux-setup-storage'
alias repo='termux-change-repo'
alias pi='nala install'
alias pup='nala update'
alias pug='nala upgrade -y'
alias aup='nala update'
alias apg='nala upgrade -y'
alias c='cd ..'
alias etc='cd $PREFIX/etc'
alias n='nvim'
alias p='pip install'
alias d='rm -rf'
alias ex='unzip'
alias f='mkdir'
alias z='vi ~/.zshrc'
alias cdd='cd $HOME/storage/downloads'
alias ax='acodeX-server'
alias rr='source ~/.zshrc'
alias vps='ssh root@192.xxx.xx.xx' #add your vps ip

# Safety aliases
alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -i'
alias cpr='cp -r'

# Powerlevel10k config (keep at bottom)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
