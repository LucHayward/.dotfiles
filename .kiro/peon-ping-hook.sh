#!/usr/bin/env bash

set -euo pipefail

peon_dir="${CLAUDE_PEON_DIR:-$HOME/.claude/hooks/peon-ping}"
[[ -f "$peon_dir/peon.sh" ]] || exit 0

python3 -c '
import json
import sys

event = json.load(sys.stdin)
event["source"] = "kiro"
session_id = str(event.get("session_id", ""))
if session_id and not session_id.startswith("kiro-"):
    event["session_id"] = f"kiro-{session_id}"
json.dump(event, sys.stdout)
' | bash "$peon_dir/peon.sh"
