# Claude settings

`~/.claude/settings.json` points to the real file in this directory. Claude or
Toolbox may replace that link with a new regular file. `claude-settings-sync repair`
validates and captures the live contents before restoring the link. It works
while Claude is running. If the file actually changes during capture, it keeps
the newer live write and leaves relinking for a later run.

The shell repairs settings after direct `toolbox update` commands. The standalone
`~/.dotfiles/update-all` script repairs once at the end, after AIM finishes.
The macOS installer loads a daily 09:00 LaunchAgent that also runs when loaded at
login. A scheduled run missed during sleep runs after wake. Source the updated
`.zshrc` or open a new shell to enable the Toolbox wrapper.

Run `~/.dotfiles/claude-settings-sync repair` manually when needed. `diff` shows
drift, `pull` captures without relinking, and `push` explicitly restores the repo
version, backing up the live file first. Backups live in
`~/.claude/settings-backups/`. Git commits and pushes remain normal manual steps.
