#!/usr/bin/env python3
"""Prune noisy and duplicate PeonPing-managed Codex hooks."""

from pathlib import Path
import re
import sys


BLOCK_START = "# peon-ping Codex hooks begin"
BLOCK_END = "# peon-ping Codex hooks end"
BLOCK_PATTERN = re.compile(
    rf"(?ms)^{re.escape(BLOCK_START)}\n.*?^{re.escape(BLOCK_END)}(?:\n|$)"
)
DISABLED_EVENTS = {
    "PermissionRequest",
    "PostToolUse",
    "PreToolUse",
    "SubagentStart",
    "SubagentStop",
    "UserPromptSubmit",
}
DISABLED_STATE_EVENTS = {
    "permission_request",
    "post_tool_use",
    "pre_tool_use",
    "subagent_start",
    "subagent_stop",
    "user_prompt_submit",
}
HOOK_HEADER = re.compile(
    r"^\[\[hooks\.([A-Za-z0-9_]+)(?:\.hooks)?\]\]$"
)
STATE_HEADER = re.compile(
    r'^\[hooks\.state\."[^"]*:([a-z_]+):\d+:\d+"\]$'
)


def should_remove_section(header: str) -> bool:
    hook_match = HOOK_HEADER.fullmatch(header)
    if hook_match:
        return hook_match.group(1) in DISABLED_EVENTS

    state_match = STATE_HEADER.fullmatch(header)
    return bool(state_match and state_match.group(1) in DISABLED_STATE_EVENTS)


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


def prune_config(config: str) -> str:
    blocks = list(BLOCK_PATTERN.finditer(config))
    if not blocks:
        return config

    latest = blocks[-1]
    latest_text = latest.group()
    content_start = latest_text.find("\n") + 1
    content_end = latest_text.rfind(BLOCK_END)
    managed_block = latest_text[content_start:content_end]
    pruned_block = prune_managed_block(managed_block)
    trailing_newline = "\n" if latest_text.endswith("\n") else ""
    latest_replacement = (
        f"{BLOCK_START}\n{pruned_block}{BLOCK_END}{trailing_newline}"
    )

    retained_parts = []
    cursor = 0
    for block in blocks:
        retained_parts.append(config[cursor:block.start()])
        if block is latest:
            retained_parts.append(latest_replacement)
        cursor = block.end()
    retained_parts.append(config[cursor:])
    return "".join(retained_parts)


def main() -> int:
    config_path = (
        Path(sys.argv[1]).expanduser()
        if len(sys.argv) > 1
        else Path.home() / ".codex" / "config.toml"
    )
    if not config_path.is_file():
        return 0

    config = config_path.read_text(encoding="utf-8")
    pruned_config = prune_config(config)
    if pruned_config == config:
        return 0

    config_path.write_text(pruned_config, encoding="utf-8")
    print(f"Pruned PeonPing Codex hooks in {config_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
