# Load zgen
source ~/.zgen/zgen.zsh

if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen load zsh-users/zsh-syntax-highlighting

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
    zgen oh-my-zsh themes/minimal

    # save all to init script
    zgen save
fi

# Load custom scripts
source ~/.zgen/custom/zbell.sh

# configure zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[path]='fg=45,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=45'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=196'

# Disable auto cd
unsetopt AUTO_CD

# exports
export EDITOR='vim'
export PATH="/home/miccah/bin:$PATH"

export school=~/documents/school/ut/spring-2016

# binds
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward
bindkey -M vicmd 'v' edit-command-line
bindkey -M viins 'jk' vi-cmd-mode

# ls colors
eval `dircolors -b ~/.dircolors`

# aliases
alias mv="mv -i"
alias cp="cp -i"
alias pacman="pacman --color=auto"
alias feh="feh --scale-down"
alias youtube-viewer="youtube-viewer --video-player=mpv"
alias matlab="matlab -nodesktop -nosplash"
alias octave="octave-cli"

alias open="xdg-open"
alias noblank="xset -dpms; xset s noblank; xset s off"
alias blank="xset +dpms; xset s blank; xset s on"
alias ssid="iw wlp3s0 link | grep 'SSID' | sed 's/[ \t]*SSID: //g'"
alias battery="acpi | awk -F\"[,,]\" '{print \$2}' | cut -c 2-"
alias since="ps -o etime= -p"

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
