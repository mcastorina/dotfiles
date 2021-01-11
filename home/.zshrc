# Disable oh-my-zsh update prompt
export DISABLE_AUTO_UPDATE="true"
if [ ! -f ~/.zgen/zgen.zsh ]; then
    # Install zgen
    mkdir -p ~/.zgen && cd ~/.zgen
    git init
    git remote add origin https://github.com/tarjoilija/zgen.git
    git fetch
    git checkout --track origin/master
fi
source ~/.zgen/zgen.zsh

if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    # zgen oh-my-zsh plugins/last-working-dir
    zgen load zsh-users/zsh-syntax-highlighting

    # completions
    zgen load zsh-users/zsh-completions src
    zgen load tarruda/zsh-autosuggestions

    # theme
    zgen load ~/.zgen/custom/miccah.zsh-theme

    # save all to init script
    zgen save
fi

# Load custom scripts
# source ~/.zgen/custom/zbell.sh

# configure zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[path]='fg=45,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=45'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=196'

# Set / unset options
setopt extendedglob notify
unsetopt autocd beep

# Set history config
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(history|exit)"

# exports
export EDITOR='vim'
export PATH="$HOME/bin:$PATH"

# binds
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward
bindkey '^f' vi-forward-blank-word
bindkey '^l' vi-end-of-line
bindkey '^p' sudo-command-line
bindkey -M vicmd 'v' edit-command-line
bindkey -M viins 'jk' vi-cmd-mode

# ls colors
eval `dircolors -b ~/.dircolors`

# aliases
alias mv="mv -i"
alias cp="cp -i"
alias feh="feh --scale-down"
alias youtube-viewer="youtube-viewer --video-player=mpv --append-arg='--input-ipc-server /tmp/mpvsocket' --resolution=720p"
alias mpv="mpv --input-ipc-server /tmp/mpvsocket"
alias yay="yay --color=always"

alias open="xdg-open"
alias noblank="xset -dpms; xset s noblank; xset s off"
alias blank="xset +dpms; xset s blank; xset s on"
alias ssid="iw wlp3s0 link | grep 'SSID' | sed 's/[ \t]*SSID: //g'"
alias battery="acpi | awk -F\"[,,]\" '{print \$2}' | cut -c 2-"
alias since="ps -o etime= -p"
alias weather="curl http://wttr.in 2>/dev/null"
alias search="rg --line-number --ignore-case"
alias wifi-on="sudo systemctl start netctl-auto@wlp3s0.service"
alias wifi-off="sudo systemctl stop netctl-auto@wlp3s0.service"

# functions
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        bg
        zle redisplay
    else
        zle push-input
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# if no options are given, then wget clipboard
wget () {
    if [[ $# -eq 0 ]]; then
        /usr/bin/wget -- $(xsel -ob)
    else
        /usr/bin/wget $@
    fi
}

# mkdir && cd
new () {
    /usr/bin/mkdir "$@" && cd "${@: -1}"
}
# mkdir && mv
store () {
    /usr/bin/mkdir -p "${@: -1}" && mv "${@: 1 : -1}" "${@: -1}"
}

# fork and redirect zathura output
zathura () {
    /usr/bin/zathura --fork $@ &> /dev/null
}
