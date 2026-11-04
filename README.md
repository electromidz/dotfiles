# dotfiles — Arch Linux + dwm

My Arch desktop in one repo: **dwm**, **st**, **dmenu**, **dwmblocks** status bar,
pywal colours from the wallpaper, picom, dunst, slock, Nerd Fonts, zsh + oh-my-zsh,
neovim (LazyVim) and more.

## Install

On a fresh Arch install (with a user that has `sudo`):

```sh
sudo pacman -S --needed git
git clone https://github.com/<your-username>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then reboot and log in on tty1 — dwm starts on its own.
Put wallpapers in `~/Pictures/Backgrounds`; colours are picked from a random one at each login.

## What the script does

1. Installs packages from `packages/` (`core.txt`, `fonts.txt`, optional `apps.txt`, AUR `aur.txt`)
2. Installs `yay` if it's missing
3. Symlinks everything in `home/` into `~` (old files go to `~/.dotfiles-backup-<date>`)
4. Links `~/suckless` → this repo's `suckless/`, then builds dwm, st, dmenu, dwmblocks
5. Enables NetworkManager, bluetooth, pipewire; sets zsh as your shell

Because files are **symlinked**, editing `~/.config/...` or `~/suckless/...` edits the repo.
Commit and push to save changes.

## Layout

```
install.sh          the one command
packages/           package lists (one per line, # for comments)
suckless/           dwm, st, dmenu, dwmblocks sources with my patches + config.h
  dwmblocks/blocks/ status bar scripts (battery, wifi, volume, clock, BTC…)
home/               files that go into ~  (.xinitrc, .zshrc, .config/…, .local/bin/…)
```

## Change things

- Keybindings / gaps / fonts: `suckless/dwm/config.h`, then `cd ~/suckless/dwm && sudo make install`
- Status bar blocks: `suckless/dwmblocks/config.h`, then `make install PREFIX=~/.local`
- Add a package: add a line to a file in `packages/`
