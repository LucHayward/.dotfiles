# Global Codex conventions

## Reuse existing workspaces

For implementation work in packages under `~/workplace`, reuse the existing workspace instead of creating a nested or sibling workspace.

When the existing checkout is dirty:

1. Inspect the changes and current branch.
2. Preserve the changes with a WIP commit on a dedicated temporary branch. Never add a WIP commit directly to `mainline`; create the preservation branch first when necessary.
3. Create the task branch from `origin/mainline` in the same workspace.
4. Do not create a new workspace merely because the checkout is dirty.

Stop and ask before committing if the dirty state appears to contain secrets, generated bulk data, or files that should not enter git history.
