#!/usr/bin/env bash
# One-command setup for an Arch Linux dwm desktop (made for a ThinkPad X1 Carbon).
#
#   git clone git@github.com:electromidz/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./install.sh
#
# Run as your normal user (not root). Safe to run again: existing files
# are moved to ~/.dotfiles-backup-<date> before being replaced.
#
# Answer the questions up front, or skip them:
#   ./install.sh --all     install every optional group without asking

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
ALL=no; [ "${1:-}" = --all ] && ALL=yes

info() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
ask()  { [ $ALL = yes ] && return 0; local a; read -rp "$1 [Y/n] " a; [[ $a != [nN]* ]]; }

# Read a package list, skipping comments and blank lines
pkgs() { grep -vE '^\s*(#|$)' "$DOTS/packages/$1"; }

# Move an existing file out of the way, then symlink ours in its place
link() {
	local src=$1 dst=$2
	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
		mv "$dst" "$BACKUP/${dst#"$HOME"/}"
	fi
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	echo "  linked ${dst/#$HOME/\~}"
}

# Copy a file from system/ to the same place under /
sysfile() {
	sudo install -D -m "${2:-644}" "$DOTS/system/$1" "/$1"
	echo "  installed /$1"
}

[ "$EUID" -eq 0 ] && { echo "Run this as your normal user, not root."; exit 1; }
[ -f /etc/arch-release ] || { echo "This script is for Arch Linux."; exit 1; }

# ---------------------------------------------------------------- questions
info "Choose what to install (Enter = yes)"
ask "ThinkPad hardware support (Intel GPU, audio firmware, zram, touchpad, battery care)?" && HW=yes || HW=no
ask "Developer tools (docker, node via nvm, rust, go, github-cli, mise)?" && DEV=yes || DEV=no
ask "Desktop apps (firefox, chromium, kitty, mpv, vlc, telegram, discord, localsend...)?" && APPS=yes || APPS=no

# Keep sudo alive while the script runs
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# ---------------------------------------------------------------- packages
info "Installing packages (pacman)"
list=$(pkgs core.txt; pkgs fonts.txt)
[ $HW = yes ]   && list+=" $(pkgs thinkpad.txt)"
[ $DEV = yes ]  && list+=" $(pkgs dev.txt)"
[ $APPS = yes ] && list+=" $(pkgs apps.txt)"
# shellcheck disable=SC2086
sudo pacman -Syu --needed --noconfirm $list

if ! command -v yay >/dev/null; then
	info "Installing yay (AUR helper)"
	tmp=$(mktemp -d)
	git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
	(cd "$tmp/yay-bin" && makepkg -si --noconfirm)
	rm -rf "$tmp"
fi

info "Installing AUR packages"
aur=$(pkgs aur.txt)
[ $APPS = yes ] && aur+=" $(pkgs aur-apps.txt)"
# shellcheck disable=SC2086
yay -S --needed --noconfirm $aur

# ---------------------------------------------------------------- dotfiles
info "Linking config files"
# Every file under home/ is linked to the same place in $HOME.
# Folders inside .config are linked whole, so new files show up in git.
while IFS= read -r -d '' f; do
	rel=${f#"$DOTS/home/"}
	link "$f" "$HOME/$rel"
done < <(find "$DOTS/home" -mindepth 1 -maxdepth 1 ! -name .config ! -name .local -print0)

for f in "$DOTS"/home/.config/*; do
	name=$(basename "$f")
	if [ "$name" = wal ]; then
		# keep ~/.config/wal a real folder so pywal can write next to it
		mkdir -p "$HOME/.config/wal"
		link "$f/templates" "$HOME/.config/wal/templates"
		link "$f/colorschemes" "$HOME/.config/wal/colorschemes"
	else
		link "$f" "$HOME/.config/$name"
	fi
done

for f in "$DOTS"/home/.local/bin/*; do
	link "$f" "$HOME/.local/bin/$(basename "$f")"
done

# dunst reads the colours pywal generates
mkdir -p "$HOME/.config/dunst" "$HOME/.cache/wal"
ln -sfn "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"

# dwm's keys and scripts expect the sources at ~/suckless
link "$DOTS/suckless" "$HOME/suckless"

# ---------------------------------------------------------------- shell, tmux, neovim
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	info "Installing oh-my-zsh"
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
		"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

info "Installing tmux plugins (Tokyo Night theme, yank)"
[ -d "$HOME/.tmux/plugins/tpm" ] ||
	git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tmux plugins failed; press prefix+I inside tmux"

info "Installing LazyVim plugins (takes a minute)"
nvim --headless "+Lazy! restore" +qa || warn "Neovim plugins failed; they will install when you open nvim"

# ---------------------------------------------------------------- build
info "Building dwm, st, dmenu"
for p in dwm st dmenu; do
	(cd "$DOTS/suckless/$p" && make clean && make && sudo make install)
done

info "Building dwmblocks"
(cd "$DOTS/suckless/dwmblocks" && make clean && make && make install PREFIX="$HOME/.local")
cc -O2 -o "$DOTS/suckless/dwmblocks/blocks/xkb-group" \
	"$DOTS/suckless/dwmblocks/blocks/xkb-group.c" -lX11
chmod +x "$DOTS"/suckless/dwmblocks/blocks/* "$DOTS"/home/.local/bin/*

# ---------------------------------------------------------------- system
info "System settings"
# NetworkManager uses iwd for Wi-Fi (the interface is called wlan0)
sysfile etc/NetworkManager/conf.d/wifi-backend.conf

if [ $HW = yes ]; then
	sysfile etc/X11/xorg.conf.d/30-touchpad.conf
	sysfile etc/systemd/zram-generator.conf
	# Battery care (Super+F4): lets dwm set charge limits without a password
	sysfile usr/local/bin/battery-care-set 755
	sudo visudo -cf "$DOTS/system/sudoers-battery-care" >/dev/null
	sudo install -m 440 "$DOTS/system/sudoers-battery-care" /etc/sudoers.d/battery-care
	echo "  installed /etc/sudoers.d/battery-care"
fi

info "Enabling services"
sudo systemctl enable NetworkManager bluetooth power-profiles-daemon fstrim.timer
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service || true
sudo sensors-detect --auto >/dev/null || true

# ---------------------------------------------------------------- dev tools
if [ $DEV = yes ]; then
	info "Setting up developer tools"
	sudo systemctl enable docker
	sudo usermod -aG docker "$USER"
	rustup default stable
	if [ ! -d "$HOME/.nvm" ]; then
		git clone --depth 1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
	fi
	# shellcheck disable=SC1091
	(set +eu; . "$HOME/.nvm/nvm.sh" && nvm install --lts)
fi

# ---------------------------------------------------------------- finish
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Backgrounds" "$HOME/Notes"
fc-cache -f >/dev/null

if [ "$(basename "${SHELL:-}")" != zsh ]; then
	info "Making zsh your shell"
	chsh -s /usr/bin/zsh
fi

info "Done!"
[ -d "$BACKUP" ] && echo "  Your old files were moved to: $BACKUP"
if [ -z "$(ls -A "$HOME/Pictures/Backgrounds")" ]; then
	warn "Copy your wallpapers into ~/Pictures/Backgrounds - pywal picks the"
	warn "colours for dwm, st and dunst from a random one at login."
fi
echo "  Reboot, log in on tty1, and dwm starts on its own."
