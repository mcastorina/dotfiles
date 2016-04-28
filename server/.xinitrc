#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# screen resolution
xrandr -d :0 --output HDMI-0 --mode 1360x768

# wallpaper
feh --bg-scale $HOME/.wallpaper &

# clipboard
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

# disable screen blank
xset -dpms &
xset s noblank &
xset s off &

# keybinds
xbindkeys &

# more space for popcorntime
if ! [ -L /tmp/Popcorn-Time ] ; then
    ln -s $HOME/tmp/Popcorn-Time /tmp/Popcorn-Time &
fi

# make mouse invisible after 5 seconds of inactivity
unclutter -idle 5 &

# start i3
exec /usr/bin/i3
