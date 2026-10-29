# appimage-sort

A small CLI utility that organizes AppImage files from `~/Downloads` into `~/.local/app` and creates lowercase symlinks in `~/.local/bin` so they can be run from anywhere.

## What it does

1. Scans `~/Downloads` for `*.AppImage` files
2. Strips version info from the filename (e.g. `Obsidian-1.7.4.AppImage` → `Obsidian.AppImage`)
3. Moves the file to `~/.local/app/`
4. Makes it executable
5. Creates a lowercase symlink in `~/.local/bin/` (e.g. `obsidian`)

## Requirements

- [Zig](https://ziglang.org/download/) (nightly / master)
- `~/.local/bin` must be in your `PATH` (see below)

## Installation

```sh
git clone https://github.com/r3xye/appimage-sort
cd appimage-sort
zig build -Doptimize=ReleaseSafe
cp zig-out/bin/appimage_sort ~/.local/bin/appimage-sort
```

## Usage

Drop your AppImage files into `~/Downloads`, then run:

```sh
appimage-sort
```

## Adding `~/.local/bin` to PATH

If commands installed to `~/.local/bin` are not found, add the following line to your shell config:

**Bash** (`~/.bashrc` or `~/.bash_profile`):
```sh
export PATH="$HOME/.local/bin:$PATH"
```

**Zsh** (`~/.zshrc`):
```sh
export PATH="$HOME/.local/bin:$PATH"
```

**Fish** (`~/.config/fish/config.fish`):
```fish
fish_add_path ~/.local/bin
```

Then reload your shell:
```sh
source ~/.bashrc   # or ~/.zshrc, depending on your shell
```
