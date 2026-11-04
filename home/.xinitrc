#!/bin/sh

# Kill any running picom/compton first
pkill picom 2>/dev/null
pkill compton 2>/dev/null
sleep 0.5

# Load static Xresources first, then the wal-generated colors (if they exist)
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
[ -f ~/.cache/wal/xrdb_extra ] && xrdb -merge ~/.cache/wal/xrdb_extra

#setxkbmap -layout us,ir -option grp:alt_shift_toggle
setxkbmap -layout us,ir -option grp:win_space_toggle

# Used by status bar click actions
export TERMINAL=st
export EDITOR=nvim

# Start the wallpaper/color script in the background.
# Wait for dwm first: the script presses dwm's "reload colors" key at the end.
(sleep 2; ~/suckless/dwmblocks/blocks/wal) &

unset https_proxy

[ -x ~/.config/dunst/startup.sh ] && ~/.config/dunst/startup.sh

killall -q dunst

dunst &

# Lock the screen with slock before the laptop sleeps (lid close, suspend)
xss-lock -- slock &

# xss-lock also locks when the screen blanks after ~10 min of no activity.
# Uncomment the next line to turn off auto-blank (then it only locks on sleep).
# xset s off

# Start dwmblocks BEFORE exec dwm, otherwise it never runs
(cd ~/suckless/dwmblocks && exec dwmblocks) &

# Replace shell with dwm (must be last)
exec dwm
