# dotfiles — Arch Linux + dwm (ThinkPad X1 Carbon)

My Arch desktop in one repo: **dwm**, **st**, **dmenu**, **dwmblocks** status bar,
pywal colours from the wallpaper, picom, dunst, slock, Nerd Fonts, zsh + oh-my-zsh + starship,
tmux (Tokyo Night), neovim (LazyVim), yazi, lazygit, btop, kitty and more.

## Install on a new laptop

1. Install Arch (e.g. `archinstall`, profile **minimal**, audio **pipewire**,
   network **NetworkManager**). Create your user with sudo access. No desktop or display manager needed.
2. Log in on the console and run:

```sh
sudo pacman -S --needed git github-cli
gh auth login                      # repo is private, so log in first
gh repo clone electromidz/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh                       # or ./install.sh --all to skip the questions
```

3. Copy your wallpapers into `~/Pictures/Backgrounds` (USB stick, scp, ...).
4. Reboot, log in on tty1 — dwm starts on its own.

The script asks three questions first (Enter = yes):

| Group | What you get |
|---|---|
| ThinkPad hardware | Intel GPU + video drivers, `sof-firmware` (speakers/mic), microcode, zram, fwupd, touchpad tap-to-click, battery care (Super+F4) |
| Developer tools | docker, node (nvm), rust (rustup), go, github-cli, mise, pip/pipx |
| Desktop apps | firefox, chromium, kitty, mpv, vlc, zathura, nautilus, telegram, discord, yt-dlp, localsend, zennotes, calcure |

## What the script does

1. Installs packages from `packages/` (pacman lists + AUR lists via `yay`)
2. Symlinks everything in `home/` into `~` (old files go to `~/.dotfiles-backup-<date>`)
3. Installs oh-my-zsh, tmux plugins (TPM), LazyVim plugins (same versions as `lazy-lock.json`)
4. Links `~/suckless` → this repo's `suckless/`, then builds dwm, st, dmenu, dwmblocks
5. Copies files from `system/` into `/etc` (iwd Wi-Fi backend, touchpad, zram, battery helper)
6. Enables NetworkManager, bluetooth, pipewire, fstrim (and docker); sets zsh as your shell

Because files are **symlinked**, editing `~/.config/...` or `~/suckless/...` edits the repo.
Commit and push to save changes:

```sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

## Layout

```
install.sh          the one command
packages/           package lists (one per line, # for comments)
  core.txt fonts.txt          always installed
  thinkpad.txt dev.txt apps.txt   optional groups
  aur.txt aur-apps.txt        AUR (yay)
suckless/           dwm, st, dmenu, dwmblocks sources with my patches + config.h
  dwmblocks/blocks/ status bar scripts (battery, wifi, volume, clock, BTC…)
home/               files that go into ~  (.xinitrc, .zshrc, .tmux.conf, .config/…, .local/bin/…)
system/             files that go into /etc and /usr/local/bin
```

## Change things

- Keybindings / gaps / fonts: `suckless/dwm/config.h`, then `cd ~/suckless/dwm && make && sudo make install`
- Status bar blocks: `suckless/dwmblocks/config.h`, then `make && make install PREFIX=~/.local`
- Add a package: add a line to a file in `packages/`

## Notes

- Keyboard: `us` + `ir` layouts, switch with Super+Space (set in `.xinitrc`).
- Git commit signing is not copied: make a new SSH key on the new laptop
  (`ssh-keygen -t ed25519`) and add it to GitHub.
- A few dwm shortcuts open programs that are not installed (screenshot, fff, termusic,
  qutebrowser, darktable, …) — same as on the old laptop. Install them or change the keys in `config.h`.
