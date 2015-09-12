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


export EDITOR='vim'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/miccah/bin"

bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward
bindkey -M vicmd v edit-command-line

# ls colors
eval `dircolors -b ~/.dircolors`

# aliases
alias noblank="xset -dpms; xset s noblank; xset s off"
alias blank="xset +dpms; xset s blank; xset s on"

alias pacman="pacman --color=auto"

alias ssid="iw wlp3s0 link | grep 'SSID' | sed 's/[ \t]*SSID: //g'"
alias battery="acpi | awk -F\"[,,]\" '{print \$2}' | cut -c 2-"

alias youtube-viewer="youtube-viewer --video-player=mpv"
alias since="ps -o etime= -p"

alias public-ip="curl icanhazip.com"

alias mv="mv -i"
alias cp="cp -i"

export school=~/documents/school/ut/fall-2015

# Disable using askpass for ssh authentication
unset SSH_ASKPASS
