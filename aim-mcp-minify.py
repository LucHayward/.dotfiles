#!/usr/bin/env python3
"""
aim-mcp-minify — deterministic de-duplicator for AIM-generated Claude Code plugins.

WHY THIS EXISTS
---------------
AIM packages each capability as its own Claude Code plugin and writes a *self-
contained* `.mcp.json` per plugin (`~/.aim/cc-plugins/<plugin>/.mcp.json`).
Unlike Kiro (where each AGENT declares its own scoped `mcpServers` with
`--include-tools` filters), Claude Code has NO per-agent MCP scoping: every MCP
server in every *enabled* plugin spawns session-wide, namespaced per plugin
(`mcp__plugin_<plugin>_<server>__*`). There is no cross-plugin de-dup.

Result: with the AIPowerUserCapabilities-* plugins enabled, `builder-mcp`
(~40 tools) loads 4-5x, plus pippin/spec-studio/coe load 2-3x each — hundreds of
duplicate tool definitions flooding the context window every session.

WHAT THIS DOES (within ~/.aim/cc-plugins ONLY — never touches ~/.claude.json or
your enabledPlugins):
  * Looks only at plugins that are ENABLED in ~/.claude/settings.json. Disabled
    plugins are left fully intact, so enabling one later restores its complete
    config (and a re-run re-dedups).
  * builder-mcp: the global ~/.claude.json already provides its tools to every
    session, so the plugin copies' only unique value is the `--agent-sop-filter`
    slash commands. We CONSOLIDATE: keep builder-mcp in ONE canonical enabled
    plugin (default: core-dev) with the UNION of every enabled plugin's SOP
    filters merged in (they all share the same agent-sops dir), and strip
    builder-mcp from the other enabled plugins. Net: 5 copies -> 2 (1 global for
    tools + 1 plugin for the full set of SOP slash commands). No tools or SOPs
    are lost.
  * Other shared servers (pippin-mcp, spec-studio-mcp, coe-mcp, cr-guide-mcp,
    slack-mcp, aws-outlook-mcp, ...): kept in exactly ONE canonical enabled
    plugin, stripped from the rest. Each loads once.

It is DETERMINISTIC and IDEMPOTENT: running it twice is a no-op, and running it
after `aim update` (which regenerates the plugins from scratch) re-applies the
same de-dup. That's why it lives at the end of `update-all`.

USAGE
  aim-mcp-minify.py [--dry-run] [--verbose]
  aim-mcp-minify.py --global-sops   # also push SOP union into ~/.claude.json and
                                    # strip builder-mcp from ALL plugins (5 -> 1).
                                    # Touches the aim-managed global file; only
                                    # safe because it re-runs every update-all.
"""

import argparse
import json
import os
import sys

HOME = os.path.expanduser("~")
PLUGINS_DIR = os.path.join(HOME, ".aim", "cc-plugins")
SETTINGS = os.path.join(HOME, ".claude", "settings.json")
GLOBAL_CFG = os.path.join(HOME, ".claude.json")

# builder-mcp tools come from the global ~/.claude.json for every session, so a
# plugin copy only adds value via its --agent-sop-filter slash commands.
BUILDER = "builder-mcp"

# Preference order for which enabled plugin "owns" a shared server. Anything not
# listed sorts after these, then alphabetically — keeping the choice stable.
PREFERENCE = [
    "AIPowerUserCapabilities-core-dev",
    "AIPowerUserCapabilities-comms",
    "AIPowerUserCapabilities-research",
    "AIPowerUserCapabilities-writing",
    "AIPowerUserCapabilities-code-review",
]


def pref_key(plugin):
    """Sort key: preferred plugins first (in list order), then alphabetical."""
    return (PREFERENCE.index(plugin) if plugin in PREFERENCE else len(PREFERENCE), plugin)


def load_json(path):
    with open(path) as fh:
        return json.load(fh)


def enabled_plugin_dirs():
    """Return enabled plugin directory names (settings keys minus the @marketplace suffix)."""
    if not os.path.exists(SETTINGS):
        return []
    enabled = load_json(SETTINGS).get("enabledPlugins", {})
    dirs = []
    for key, on in enabled.items():
        if not on:
            continue
        name = key.split("@", 1)[0]  # "AIPowerUserCapabilities-core-dev@aim" -> dir name
        if os.path.isdir(os.path.join(PLUGINS_DIR, name)):
            dirs.append(name)
    return sorted(dirs, key=pref_key)


def mcp_path(plugin):
    return os.path.join(PLUGINS_DIR, plugin, ".mcp.json")


def sop_filter_globs(cfg):
    """Extract the comma-joined --agent-sop-filter globs from a builder-mcp arg list."""
    args = cfg.get("args") or []
    for i, a in enumerate(args):
        if a in ("--agent-sop-filter", "--agent-script-filter") and i + 1 < len(args):
            return [g for g in args[i + 1].split(",") if g]
    return []


def sop_paths(cfg):
    args = cfg.get("args") or []
    for i, a in enumerate(args):
        if a in ("--agent-sop-paths", "--agent-script-paths") and i + 1 < len(args):
            return args[i + 1]
    return None


def main():
    ap = argparse.ArgumentParser(description="De-duplicate AIM Claude Code plugin MCP servers.")
    ap.add_argument("--dry-run", action="store_true", help="show changes, write nothing")
    ap.add_argument("--verbose", action="store_true", help="print per-plugin detail")
    ap.add_argument("--global-sops", action="store_true",
                    help="also merge the SOP union into ~/.claude.json and strip builder-mcp "
                         "from ALL plugins (builder-mcp 5 -> 1; touches the aim-managed global file)")
    args = ap.parse_args()

    if not os.path.isdir(PLUGINS_DIR):
        print(f"aim-mcp-minify: no cc-plugins dir at {PLUGINS_DIR} — nothing to do.")
        return 0

    plugins = enabled_plugin_dirs()
    if not plugins:
        print("aim-mcp-minify: no enabled AIM plugins found — nothing to do.")
        return 0

    # Load every enabled plugin's .mcp.json.
    configs = {}
    for p in plugins:
        path = mcp_path(p)
        if os.path.exists(path):
            configs[p] = load_json(path)

    # Map: server name -> [plugins that declare it] (in preference order).
    server_owners = {}
    for p in plugins:
        for name in (configs.get(p, {}).get("mcpServers") or {}):
            server_owners.setdefault(name, []).append(p)

    # Compute the SOP-filter UNION across all enabled plugins' builder-mcp, and a
    # sop-paths dir to use (they're identical across plugins within a generation).
    sop_union, sop_dir = set(), None
    for p in plugins:
        b = (configs.get(p, {}).get("mcpServers") or {}).get(BUILDER)
        if b:
            sop_union.update(sop_filter_globs(b))
            sop_dir = sop_dir or sop_paths(b)
    sop_union = sorted(sop_union)

    # Decide the canonical owner for each server.
    canonical = {}
    for name, owners in server_owners.items():
        canonical[name] = sorted(owners, key=pref_key)[0]
    # builder-mcp: forced to its preferred enabled host so the merged SOPs land there.
    if BUILDER in server_owners and not args.global_sops:
        canonical[BUILDER] = sorted(server_owners[BUILDER], key=pref_key)[0]

    removals = []  # (plugin, server) we strip
    builder_host = canonical.get(BUILDER)

    for p in plugins:
        servers = configs.get(p, {}).get("mcpServers") or {}
        for name in list(servers):
            if name == BUILDER:
                if args.global_sops:
                    removals.append((p, name)); del servers[name]
                elif p != builder_host:
                    removals.append((p, name)); del servers[name]
                else:
                    # canonical builder host: install the merged SOP union.
                    if sop_dir and sop_union:
                        servers[name] = {
                            "command": "builder-mcp",
                            "args": ["--agent-sop-paths", sop_dir,
                                     "--agent-sop-filter", ",".join(sop_union)],
                        }
            else:
                if canonical.get(name) != p:
                    removals.append((p, name)); del servers[name]

    # Report.
    print("aim-mcp-minify — enabled plugins:", ", ".join(plugins))
    print(f"  builder-mcp SOP host: {builder_host or '(global only)'}  "
          f"({len(sop_union)} SOP globs merged)")
    if removals:
        print("  de-duplicated (stripped redundant copies):")
        for p, name in sorted(removals):
            print(f"    - {name:<22} from {p}")
    else:
        print("  already minified — no changes.")
    if args.verbose:
        for p in plugins:
            kept = list((configs.get(p, {}).get("mcpServers") or {}).keys())
            print(f"    {p}: {kept or '[]'}")

    if args.dry_run:
        print("  (dry-run: nothing written)")
        return 0

    # Write back only changed files.
    for p in plugins:
        path = mcp_path(p)
        if os.path.exists(path):
            with open(path, "w") as fh:
                json.dump(configs[p], fh, indent=2)
                fh.write("\n")

    # Optional: push the SOP union into the global ~/.claude.json builder-mcp.
    if args.global_sops and os.path.exists(GLOBAL_CFG) and sop_dir and sop_union:
        g = load_json(GLOBAL_CFG)
        b = g.get("mcpServers", {}).get(BUILDER)
        if b is not None:
            a = [x for x in (b.get("args") or [])]
            # drop any existing sop flags, then append the merged set
            cleaned, skip = [], False
            for x in a:
                if skip:
                    skip = False; continue
                if x in ("--agent-sop-paths", "--agent-script-paths",
                         "--agent-sop-filter", "--agent-script-filter"):
                    skip = True; continue
                cleaned.append(x)
            cleaned += ["--agent-sop-paths", sop_dir, "--agent-sop-filter", ",".join(sop_union)]
            b["args"] = cleaned
            with open(GLOBAL_CFG, "w") as fh:
                json.dump(g, fh, indent=2)
                fh.write("\n")
            print(f"  merged {len(sop_union)} SOP globs into global ~/.claude.json builder-mcp")

    print("  done. Changes take effect next Claude Code session (or /reload-plugins).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
