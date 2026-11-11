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

# Mirror the laptop screen onto the HDMI monitor when it's plugged in
# (Dell at 2560x1440; the 1080p laptop screen shrinks the same picture to fit)
if xrandr | grep -q '^HDMI-1 connected'; then
    xrandr --output HDMI-1 --mode 2560x1440 --rate 59.95 --pos 0x0 --primary \
           --output eDP-1 --mode 1920x1080 --rate 60 --scale-from 2560x1440 --same-as HDMI-1
fi

# Text/UI scale: 96 DPI = 100%. Set here because ~/.Xresources is rewritten by wal.
echo 'Xft.dpi: 96' | xrdb -merge

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

# Give background services (file picker portal, etc.) access to this X display.
# Without this, browser "Upload file" dialogs never open.
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

# Replace shell with dwm (must be last)
exec dwm
