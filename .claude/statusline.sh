#!/bin/bash
# Both renderers need the complete Claude session JSON from stdin.
payload="$(cat)"

# Amazon renders relevant service alerts above this Midway-only row.
# A missing or failing Toolbox install must not suppress cship.
if [[ -x "$HOME/.toolbox/bin/claude" ]]; then
    printf '%s\n' "$payload" |
        "$HOME/.toolbox/bin/claude" amzn-statusline \
            --format '🔑 Midway: {midway_session_length}' |
        awk '{
            plain = $0
            gsub(/\033\[[0-9;]*m/, "", plain)
            # Keep alerts and login failures; hide countdowns of at least 1h.
            if (plain !~ /^🔑 Midway: [1-9][0-9]*h /) print
        }' || true
fi

# Use the Cargo installation even when Claude's PATH omits ~/.cargo/bin.
cship_bin="${CARGO_HOME:-$HOME/.cargo}/bin/cship"
if [[ ! -x "$cship_bin" ]]; then
    cship_bin="cship"
fi
printf '%s\n' "$payload" | "$cship_bin"
