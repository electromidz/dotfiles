#!/usr/bin/env bash
# One-command setup for an Arch Linux dwm desktop.
#
#   git clone https://github.com/<you>/dotfiles ~/dotfiles
#   cd ~/dotfiles && ./install.sh
#
# Run as your normal user (not root). Safe to run again: existing files
# are moved to ~/.dotfiles-backup-<date> before being replaced.

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
ask()  { local a; read -rp "$1 [y/N] " a; [[ $a == [yY]* ]]; }

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

[ "$EUID" -eq 0 ] && { echo "Run this as your normal user, not root."; exit 1; }
[ -f /etc/arch-release ] || { echo "This script is for Arch Linux."; exit 1; }

# ---------------------------------------------------------------- packages
info "Installing packages (pacman)"
sudo pacman -Syu --needed --noconfirm $(pkgs core.txt) $(pkgs fonts.txt)

if ask "Install optional apps from packages/apps.txt?"; then
	sudo pacman -S --needed --noconfirm $(pkgs apps.txt)
fi

if ! command -v yay >/dev/null; then
	info "Installing yay (AUR helper)"
	tmp=$(mktemp -d)
	git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
	(cd "$tmp/yay-bin" && makepkg -si --noconfirm)
	rm -rf "$tmp"
fi

info "Installing AUR packages"
yay -S --needed --noconfirm $(pkgs aur.txt)

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

# ---------------------------------------------------------------- oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	info "Installing oh-my-zsh"
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
		"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ---------------------------------------------------------------- build
info "Building dwm, st, dmenu"
for p in dwm st dmenu; do
	(cd "$DOTS/suckless/$p" && make clean && sudo make install)
done

info "Building dwmblocks"
(cd "$DOTS/suckless/dwmblocks" && make clean && make install PREFIX="$HOME/.local")
cc -O2 -o "$DOTS/suckless/dwmblocks/blocks/xkb-group" \
	"$DOTS/suckless/dwmblocks/blocks/xkb-group.c" -lX11
chmod +x "$DOTS"/suckless/dwmblocks/blocks/* "$DOTS"/home/.local/bin/*

# ---------------------------------------------------------------- system
info "Enabling services"
sudo systemctl enable NetworkManager bluetooth power-profiles-daemon
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service || true
sudo sensors-detect --auto >/dev/null || true

xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Backgrounds" "$HOME/Notes"
fc-cache -f >/dev/null

if [ "$(basename "${SHELL:-}")" != zsh ]; then
	info "Making zsh your shell"
	chsh -s /usr/bin/zsh
fi

# ---------------------------------------------------------------- done
info "Done!"
[ -d "$BACKUP" ] && echo "  Your old files were moved to: $BACKUP"
if [ -z "$(ls -A "$HOME/Pictures/Backgrounds")" ]; then
	warn "Put some wallpapers in ~/Pictures/Backgrounds - pywal picks the"
	warn "colours for dwm, st and dunst from a random one at login."
fi
echo "  Reboot, log in on tty1, and dwm starts on its own."
