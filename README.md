# dotfiles

Personal dotfiles for automating the setup of a new machine (macOS and Linux).

## Install

```sh
git clone <this-repo> ~/.dotfiles
cd ~/.dotfiles
./common_install.sh        # prompts for each section; pass -y to skip prompts
```

The installer symlinks configs into place and then runs the OS-specific script
(`mac_install.sh` / `linux_install.sh`). Some steps need interaction — YubiKey
for `mwinit`, and a reboot after installing the Brazil CLI.

## Branches

- **`main`** — the config for my personal machine.
- **`aws`** — the work machine, and the branch I primarily keep up to date.

In practice most day-to-day changes land on `aws` first, then the
machine-agnostic bits get merged back into `main`. This is backwards from the
usual "main is the source of truth" flow and worth fixing at some point —
ideally with shared config on `main` and thin machine-specific overlays on top.

## What's in here

- **Shell** — `.zshrc`, `.zshenv`, `.zprofile`, `.zlogin`, [starship](starship.toml) prompt, [mise](mise/config.toml) runtime manager
- **Git** — `.gitconfig`, global ignores
- **Terminal / editors** — iTerm2, Sublime, `.vimrc`, `bat`
- **AI tooling** — Claude Code, Kiro, and Codex configs and rules under `.claude/`, `.kiro/`, `.codex/`; PeonPing notifications are installed and configured by the macOS installer
- **Apps** — Firefox, Obsidian, Raycast, Karabiner, Unison sync
- **Install scripts** — `common_install.sh` plus per-OS scripts

Configs live in this repo and are symlinked to their expected locations, so
edits here take effect directly.

## Shell startup caching

To keep shell startup fast, `.zshrc` avoids re-running slow `eval "$(tool ...)"`
initializers on every launch. Two helpers handle this:

- **`cached_eval`** — writes a tool's init output to `~/.cache/zsh-init/` and
  sources that instead, regenerating only when the tool's binary is newer than
  the cache. Used for `mise activate`.
- **`lazy_cached_eval`** — same caching, but defers generating and sourcing the
  script until the command is first tab-completed. Used for the large `uv` /
  `uvx` completion scripts, which then cost nothing in shells where they're
  never used.

If a tool misbehaves after an upgrade, `rm ~/.cache/zsh-init/*.zsh` forces a
clean regenerate on next launch.
