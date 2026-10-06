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
- **AI tooling** — Claude Code, Kiro, and Codex configs and rules under `.claude/`, `.kiro/`, and `.codex/`; Amazon Codex wrapper settings under `config/amzn-openaicodex/`
- **Apps** — Firefox, Obsidian, Raycast, Karabiner, Unison sync
- **Install scripts** — `common_install.sh` plus per-OS scripts

Configs live in this repo and are symlinked to their expected locations, so
edits here take effect directly.

## Updating tools

Run `update-all` in your shell, or `~/.dotfiles/update-all` directly. The
standalone script updates Homebrew on macOS, cship through Cargo, Toolbox, mise,
and AIM, cleans up AIM's generated files, then repairs the Claude settings
symlink once at the end.

## Claude status line

The common installer installs [cship](https://github.com/stephenleo/cship) through
Cargo on both macOS and Linux, after the OS-specific Rust setup. It links
`~/.config/cship.toml` to [`cship.toml`](cship.toml). Claude uses it through
`"statusLine": {"type": "command", "command": "cship"}` in its settings.

Run `cargo install --locked cship` to install or update just cship. The installer
and `update-all` run this command directly using Cargo from
`${CARGO_HOME:-$HOME/.cargo}/bin`. Cargo selects the latest release, uses its
locked dependencies, and skips an already current installation. Rust must be
installed first.

The second status-line row shows model, effort, cost, context percentage and
token counts, plus usage limits when available. Usage limits remain configured
for regular Claude subscriptions and render empty when unavailable on Bedrock.
Percentage formatting is scoped to percentage fields so token counts and
context size display without extra percent signs.

## Codex configuration

Native Codex reads `~/.codex/config.toml`, `AGENTS.md`, and `rules/default.rules`,
which the installer links to `.codex/` in this repo. Its config writer and the
Amazon wrapper's enterprise settings writer preserve the config symlink.

The Amazon wrapper has a separate config for its Bedrock provider choice.
The installer links its entire config directory to
[`config/amzn-openaicodex/`](config/amzn-openaicodex/config.toml):

- **macOS:** `~/Library/Application Support/com.amazon.Amzn-OpenAICodex`
- **Linux:** `${XDG_CONFIG_HOME:-$HOME/.config}/amzn-openaicodex`

Run `codex amzn directories` to confirm the wrapper paths. An existing config
directory is retained as a dated backup when the installer first replaces it.
The directory symlink keeps any defaults added by the Toolbox post-install
hook in the repo, even when the hook replaces `config.toml` atomically.
Wrapper caches and logs stay local in the reported `cache_dir`.

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
