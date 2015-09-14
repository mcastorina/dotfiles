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

# wallpaper
feh --bg-scale /home/miccah/.wallpaper &

# clipboard
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

# binds
xbindkeys &

# more space for popcorn time
if ! [ -L /tmp/Popcorn-Time ] ; then
    ln -s ~/tmp/Popcorn-Time /tmp/Popcorn-Time &
fi

# save dbus session variable
touch $HOME/.dbus/Xdbus
chmod 600 $HOME/.dbus/Xdbus
env | grep DBUS_SESSION_BUS_ADDRESS > $HOME/.dbus/Xdbus
echo 'export DBUS_SESSION_BUS_ADDRESS' >> $HOME/.dbus/Xdbus

# hide mouse cursor after idled for 10 seconds
unclutter -idle 10 &

# Start i3 and log to ~/.i3/logfile
exec /usr/bin/i3
