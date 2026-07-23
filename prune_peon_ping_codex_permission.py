#!/usr/bin/env python3
"""Remove PeonPing's non-actionable Codex permission notification hook."""

from pathlib import Path
import re
import sys


BLOCK_START = "# peon-ping Codex hooks begin"
BLOCK_END = "# peon-ping Codex hooks end"
PERMISSION_HOOK_HEADERS = {
    "[[hooks.PermissionRequest]]",
    "[[hooks.PermissionRequest.hooks]]",
}
PERMISSION_STATE_HEADER = re.compile(
    r'^\[hooks\.state\."[^"]*:permission_request:\d+:\d+"\]$'
)


def should_remove_section(header: str) -> bool:
    return (
        header in PERMISSION_HOOK_HEADERS
        or PERMISSION_STATE_HEADER.fullmatch(header) is not None
    )


def prune_managed_block(block: str) -> str:
    retained_lines = []
    removing_section = False

    for line in block.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            removing_section = should_remove_section(stripped)
        if not removing_section:
            retained_lines.append(line)

    return "".join(retained_lines)


def main() -> int:
    config_path = (
        Path(sys.argv[1]).expanduser()
        if len(sys.argv) > 1
        else Path.home() / ".codex" / "config.toml"
    )
    if not config_path.is_file():
        return 0

    config = config_path.read_text(encoding="utf-8")
    block_start = config.find(BLOCK_START)
    block_end = config.find(BLOCK_END, block_start + len(BLOCK_START))
    if block_start < 0 or block_end < 0:
        return 0

    content_start = config.find("\n", block_start)
    if content_start < 0 or content_start >= block_end:
        return 0
    content_start += 1

    managed_block = config[content_start:block_end]
    pruned_block = prune_managed_block(managed_block)
    if pruned_block == managed_block:
        return 0

    config_path.write_text(
        config[:content_start] + pruned_block + config[block_end:],
        encoding="utf-8",
    )
    print(f"Removed PeonPing Codex permission notifications from {config_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
