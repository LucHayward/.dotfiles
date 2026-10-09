# Claude settings

`~/.claude` is a symlink to this directory, so every write Claude, Toolbox or
AIM makes lands here, including atomic renames that replace `settings.json`.
Git is the sync mechanism: the root `.gitignore` tracks only the curated files
listed there. History, sessions, plugins and caches stay local and untracked.
To track another file, add a `!.claude/<path>` line to `.gitignore`.

`common_install.sh` creates the link in its symlink step, before Toolbox
installs claude-code. An existing `~/.claude` is moved aside to
`~/.claude.dotfiles-backup-*` first. Rerun that step if a tool ever replaces
the link with a real directory.

`settings.json` is shared by every host, so keep paths in it portable: write
`~/...` rather than an absolute home directory. Put host-only environment
variables in the shell config instead of the `env` block.
