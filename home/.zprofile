export PATH="$HOME/.local/bin:$PATH"
export TERMINAL=st
export EDITOR=nvim

# Start dwm automatically after logging in on tty1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi
