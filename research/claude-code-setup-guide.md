# Claude Code (Amazon Internal) — Complete Setup Guide

## Summary

Claude Code is Amazon's internal distribution of Anthropic's Claude Code CLI. It is installed via Builder Toolbox and requires **zero manual authentication setup** — credentials for Bedrock are automatically configured by the wrapper. There is no login step, no API key, no Midway auth, and no Builder ID required specifically for Claude Code. It uses a shared "Cecelia-managed" AWS account for Bedrock inference by default.

---

## Prerequisites

- **Builder Toolbox** must be installed and up-to-date
- A terminal (macOS Terminal, iTerm2, Windows Terminal, or Amazon Linux shell)
- **Access**: Automatically available to **L0 and L4+** Amazon builders. Others need manager approval to join a permission group.

### Access Groups (if not L0/L4+)

| Org | Permission Group |
|-----|-----------------|
| AWS | [kiro-subscription-aws-misc](https://permissions.amazon.com/a/team/kiro-subscription-aws-misc) |
| SDO | [kiro-subscription-sdo-misc](https://permissions.amazon.com/a/team/kiro-subscription-sdo-misc) |
| AWS (L99) | [kiro-subscription-aws-l99](https://permissions.amazon.com/a/team/kiro-subscription-aws-l99) |
| SDO (L99) | [kiro-subscription-sdo-l99](https://permissions.amazon.com/a/team/kiro-subscription-sdo-l99) |

Permissions can take up to an hour to propagate.

---

## Step-by-Step Setup

### Step 1: Check for conflicting installations

```bash
which -a claude 2>/dev/null | grep -v '\.toolbox'
```

If this produces output, remove the existing installation first (see Troubleshooting section below).

### Step 2: Install Claude Code

```bash
toolbox install claude-code
```

### Step 3: Verify installation

```bash
claude --version
which claude
```

`which claude` should return `~/.toolbox/bin/claude`.

### Step 4: Install AIM plugins (recommended, macOS/Linux only)

AIM plugins add agents, skills, and MCP servers. The core plugin provides knowledge of Amazon development workflows (Brazil, CRUX, Apollo).

```bash
toolbox install aim && aim plugins install AmazonBuilderCoreAIAgents
```

### Step 5: Launch Claude Code

```bash
cd /path/to/your/project
claude
```

Launch from the root of your project for best results.

### Step 6: Verify Builder MCP connection

Inside your Claude Code session, type:

```
/mcp
```

Confirm `builder-mcp` appears with a `✔ connected` status.

If it's missing, install manually (in a separate terminal):

```bash
aim mcp install builder-mcp
```

Then restart Claude Code and verify again.

### Step 7: Initialize project context (optional but recommended)

```
/init
```

This generates a `CLAUDE.md` file that gives Claude Code persistent context about your project.

---

## Authentication & Credentials

### How it works

- **No manual auth required.** The internal wrapper provides pre-configured Bedrock credentials automatically.
- Uses a shared **Cecelia-managed AWS account** for Bedrock access.
- No API keys, no Midway authentication, no Builder ID login.
- All inference traffic is routed through **Amazon Bedrock** (stays within Amazon's infrastructure).
- All Claude Code telemetry to Anthropic is **disabled**.

### Bring Your Own Account (BYOA) — Optional

If your team has its own AWS account with Bedrock enabled:

```bash
ada profile add \
  --profile my-team-profile \
  --provider <PROVIDER> \
  --account <ACCOUNT_ID> \
  --partition aws \
  --role <ROLE_NAME> \
  --region <REGION>
```

Then launch with:

```bash
claude --aws-profile my-team-profile
```

---

## MCP Servers & Integrations

### Builder MCP (pre-configured)

Builder MCP is **automatically configured** on first launch. It provides:

| Capability | Description |
|-----------|-------------|
| **Code search** | Search across Amazon code repositories (same backend as Code Browser) |
| **Code reviews** | Create, view, and manage code reviews |
| **Ticketing** | Create and update tickets, search issues, manage workflows |
| **Internal search** | Search internal wikis, documentation, and Amazon resources |

### Additional MCP Servers via AIM

Browse the full catalog at [AI Registry](https://ai-registry.amazon.dev/ai-capabilities/).

Install additional MCP servers with:

```bash
aim mcp install <server-name>
```

---

## Configuration

### Settings file: `~/.claude/settings.json`

```json
{
  "model": "global.anthropic.claude-opus-4-6-v1[1m]",
  "effortLevel": "high",
  "permissions": {
    "allow": [
      "Read",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)"
    ]
  }
}
```

### Model configuration

- Default: **Claude Opus** via Bedrock
- Switch interactively: `/model` command
- Set default in `~/.claude/settings.json` with the `"model"` field
- Append `[1m]` for 1M-token context window (e.g., `global.anthropic.claude-opus-4-6-v1[1m]`)

### Auto mode (skip permission prompts)

Auto mode is enabled by default in the internal distribution. Activate it with `Shift+Tab` during a session, or set permanently:

```json
{
  "permissions": {
    "defaultMode": "auto"
  }
}
```

### CLAUDE.md files

- **Project-level**: `./CLAUDE.md` in project root
- **Global**: `~/.claude/CLAUDE.md` for cross-project preferences

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `/init` | Initialize project with CLAUDE.md |
| `/mcp` | Check MCP server status |
| `/model` | Switch models |
| `/effort` | Switch reasoning effort level |
| `/resume` | Browse and resume previous sessions |
| `/doctor` | Diagnose configuration issues |
| `/plugins` | View/manage installed plugins |
| `/exit` or `Ctrl+C` | Exit |

---

## Troubleshooting

### "Unable to find a registry containing these tools"

You don't have access. Join the appropriate permission group (see Access Groups above).

### "Could not load credentials from any provider"

1. Run `toolbox update claude-code`
2. If persists, check access requirements above.

### Builder MCP not available

```bash
aim mcp install builder-mcp
```

Then restart Claude Code.

### Clean reinstall (nuclear option)

```bash
# Back up settings first!
cp ~/.claude/settings.json ~/settings-backup.json

rm -rf ~/.claude ~/.claude.json
toolbox install claude-code --verbose
```

### Remove conflicting installations

| Source | Removal command |
|--------|----------------|
| curl installer | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |

---

## Getting Help

- **Slack**: [#claude-code-internal-interest](https://amazon.enterprise.slack.com/archives/C0AT5MQUR9C)
- **Sage**: [Claude-Code tag](https://sage.amazon.dev/tags/Claude-Code)

---

## Sources

- [Claude Code - BuilderHub](https://docs.hub.amazon.dev/claude-code) — accessed 2026-06-17
- [Installing Claude Code](https://docs.hub.amazon.dev/claude-code/user-guide/getting-started-cli) — accessed 2026-06-17
- [Using Claude Code](https://docs.hub.amazon.dev/claude-code/user-guide/howto) — accessed 2026-06-17
- [Troubleshooting](https://docs.hub.amazon.dev/claude-code/user-guide/troubleshooting) — accessed 2026-06-17
- [Concepts](https://docs.hub.amazon.dev/claude-code/user-guide/concepts) — accessed 2026-06-17
- [Internal code search - Builder MCP](https://docs.hub.amazon.dev/builder-mcp/user-guide/use-cases-internal-code-search) — accessed 2026-06-17
