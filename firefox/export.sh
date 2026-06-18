#!/usr/bin/env zsh
# Exports Firefox config from the current profile into ~/.dotfiles/firefox/
# Run this anytime you've changed extensions, userChrome, etc.

set -euo pipefail

DOTFILES_FF="$HOME/.dotfiles/firefox"
FF_PROFILES="$HOME/Library/Application Support/Firefox/Profiles"

FF_PROFILE=$(find "$FF_PROFILES" -maxdepth 1 -name "*.default-release" 2>/dev/null | head -1)
if [[ -z "$FF_PROFILE" ]]; then
	echo "ERROR: No Firefox profile found" >&2
	exit 1
fi

echo "Using profile: $FF_PROFILE"

# 1. Generate policies.json from extensions.json
if [[ -f "$FF_PROFILE/extensions.json" ]]; then
	python3 -c "
import json, sys

with open('$FF_PROFILE/extensions.json') as f:
    data = json.load(f)

# Enterprise/system sources to exclude
SKIP_SOURCES = {'enterprise-policy', 'about:addons'}
SKIP_LOCATIONS = {'app-builtin', 'app-builtin-addons'}

urls = []
for addon in data.get('addons', []):
    # Skip built-in, system, enterprise-managed, themes, disabled
    if addon.get('location') in SKIP_LOCATIONS:
        continue
    if addon.get('type') != 'extension':
        continue
    info = addon.get('installTelemetryInfo') or {}
    if info.get('source') in SKIP_SOURCES:
        continue
    # Only include addons sourced from AMO
    source_uri = addon.get('sourceURI', '')
    if 'addons.mozilla.org' not in source_uri:
        continue
    # Extract slug from sourceURL or sourceURI
    # Format: https://addons.mozilla.org/firefox/downloads/file/NNNN/SLUG-VERSION.xpi
    # We use the AMO 'latest' URL pattern with the slug from installTelemetryInfo
    source_url = info.get('sourceURL', '')
    if '/addon/' in source_url:
        slug = source_url.split('/addon/')[1].split('/')[0].rstrip('?')
        urls.append(f'https://addons.mozilla.org/firefox/downloads/latest/{slug}/latest.xpi')

policies = {'policies': {'Extensions': {'Install': sorted(set(urls))}}}
with open('$DOTFILES_FF/policies.json', 'w') as f:
    json.dump(policies, f, indent=2)
    f.write('\n')
print(f'✓ policies.json: {len(urls)} extensions')
"
fi

# 2. chrome/ directory (userChrome.css + supporting CSS files)
if [[ -d "$FF_PROFILE/chrome" ]]; then
	mkdir -p "$DOTFILES_FF/chrome"
	cp "$FF_PROFILE/chrome/"*.css "$DOTFILES_FF/chrome/" 2>/dev/null
	echo "✓ chrome/ CSS files copied"
fi

# 3. user.js (Firefox preferences)
if [[ -f "$FF_PROFILE/user.js" ]]; then
	cp "$FF_PROFILE/user.js" "$DOTFILES_FF/user.js"
	echo "✓ user.js copied"
fi

echo ""
echo "Still manual:"
echo "  Sideberry: Settings → Help → Export → save as ~/.dotfiles/firefox/sideberry-settings.json"
echo "  Tampermonkey: Dashboard → Utilities → Zip → Export → save as ~/.dotfiles/firefox/tampermonkey-backup.zip"
