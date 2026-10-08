# Claude settings

`~/.claude` is a symlink to this directory, so every write Claude, Toolbox or
AIM makes lands here, including atomic renames that replace `settings.json`.
Git is the sync mechanism: the root `.gitignore` tracks only the curated files
listed there. History, sessions, plugins and caches stay local and untracked.
To track another file, add a `!.claude/<path>` line to `.gitignore`.

`claude-settings-sync repair` keeps the link in place. If `~/.claude` is a real
directory (a fresh machine, or a tool recreated it), it moves the contents in
here, keeps live files on conflict, backs up the replaced repo copies to
`settings-backups/`, and then links the directory. Moves are renames, so
running Claude sessions keep working.

The shell repairs after direct `toolbox update` commands. The standalone
`~/.dotfiles/update-all` script repairs once at the end, after AIM finishes.
The macOS installer loads a daily 09:00 LaunchAgent that also runs when loaded
at login. Run `~/.dotfiles/claude-settings-sync` to see the link state and
tracked changes. Commits and pushes remain normal manual steps.
