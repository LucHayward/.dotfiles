# Claude Code at Amazon — Setup & Configuration Guide

## Executive Summary

Claude Code is Anthropic's agentic coding CLI, officially available to all Amazon builders (L4+) since May 2026. Amazon ships an **internal distribution via Builder Toolbox** that preconfigures Bedrock routing, authentication, and Builder MCP for internal tool access. **Do not install from npm, Homebrew, or other public sources.**

The internal distribution provides:
- **Preconfigured Bedrock routing** — all inference traffic stays within Amazon's infrastructure
- **Automatic credential setup** — no manual AWS account or profile configuration required
- **Builder MCP preconfigured** — access to Amazon-internal tools (code search, code reviews, ticketing) out of the box

---

## Installation (Recommended Path)

### Prerequisites

- **L4+ Amazon builder access** (lower levels see "Unable to find a registry" error)
- **Builder Toolbox** installed and up-to-date
- **Midway authentication** valid via `mwinit --fido2`
- A terminal (macOS Terminal, iTerm2, Warp, Ghostty, etc.)

### Step 1: Check for Conflicting Installations

```bash
which -a claude 2>/dev/null | grep -v '\.toolbox'
```

If output appears, remove conflicting installs:
```bash
# Homebrew cask
brew uninstall --cask claude-code

# npm global install
npm uninstall -g @anthropic-ai/claude-code

# Anthropic's curl | bash installer
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude

# Legacy local npm install
rm -rf ~/.claude/local
```

### Step 2: Install via Builder Toolbox

```bash
toolbox install claude-code aim
```

> **Why AIM too?** AIM (AI Integration Manager) is how you add plugins like `AmazonBuilderCoreAIAgents`, which teaches Claude Code about Brazil, Apollo, CRUX, and other internal workflows.

### Step 3: Verify Installation

```bash
claude --version
which claude
# Should print: ~/.toolbox/bin/claude
```

### Step 4: Smoke Test

```bash
claude -p --output-format json "Reply with exactly: OK. No extra words." | python3 -m json.tool
```

Expected: `"is_error": false` and `"result": "OK."`

---

## First Launch & Builder MCP

```bash
cd /path/to/your/project
claude
```

Builder MCP is configured automatically on first launch. Verify:
```
/mcp
```

You should see `builder-mcp · ✔ connected`.

If missing, install manually in a second terminal:
```bash
aim mcp install builder-mcp
```

### What Builder MCP Provides

- **Code search** — search across Amazon code repositories
- **Code reviews** — create, view, manage CRs
- **Ticketing** — create/update tickets, search issues
- **Internal search** — wikis, documentation, Amazon resources

---

## Install the Amazon Builder Agent Plugin

```bash
aim plugins install AmazonBuilderCoreAIAgents
```

This installs two plugins:
- `AmazonBuilderCoreAIAgents-core` — the `amzn-builder` sub-agent + general-purpose skills (Brazil, CRUX, code reviews, wiki editing). **Ships disabled by default — enable it.**
- `AmazonBuilderCoreAIAgents-pipeline-assistant` — pipeline/Apollo troubleshooting skills. Ships enabled.

### Enable the Core Plugin

Via `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "AmazonBuilderCoreAIAgents-core@aim": true,
    "AmazonBuilderCoreAIAgents-pipeline-assistant@aim": true
  }
}
```

Or in-session: `/plugins` → toggle → `/reload-plugins`

---

## Models & Context

### Default Model

Amazon's wrapper defaults to **Claude Opus 4.6 with 1M token context window** (`global.anthropic.claude-opus-4-6-v1[1m]`).

| Alias | Resolves To |
|-------|-------------|
| `opus` | `global.anthropic.claude-opus-4-6-v1[1m]` |
| `sonnet` | `global.anthropic.claude-sonnet-4-6-v1` with 1M context |

### Switching Models

In-session: `/model`

From CLI:
```bash
claude -p --model sonnet "your prompt here"
```

In `~/.claude/settings.json`:
```json
{
  "model": "opus"
}
```

### Approved Models for Amazon Bedrock

| Supported | Permitted |
|-----------|-----------|
| Claude 4.6 Opus, Claude 4.5 Sonnet, Claude 4.5 Opus, Claude 4.5 Haiku, Claude 4.0 Sonnet | (check BuilderHub for latest list) |

---

## Configuration File: `~/.claude/settings.json`

### Minimal (internal distribution handles everything)

The Toolbox installer auto-creates this. Usually you don't need to edit it.

### Advanced Configuration (manual Bedrock setup — legacy/pilot method)

For teams that set up manually before the Toolbox distribution:

```json
{
  "awsAuthRefresh": "ada credentials update --profile <USER>-bedrock-account",
  "includeCoAuthoredBy": false,
  "env": {
    "AWS_PROFILE": "<USER>-bedrock-account",
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
    "DISABLE_BUG_COMMAND": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1"
  }
}
```

> **Note:** With the Toolbox distribution, most of these env vars are set automatically. The `claude-code-DO-NOT-DELETE` AWS profile is created on first run.

---

## IDE Integration

### VS Code

```bash
claude setup-ide   # Required first — configures ASBX Bedrock credentials
```

Then install the "Claude Code for VS Code" extension by Anthropic from the Extensions marketplace.

### JetBrains (IntelliJ, PyCharm, etc.)

Works out of the box:
1. Settings → Plugins → Marketplace
2. Search "Claude Code [Beta]" by Anthropic, PBC
3. Install and restart

### Kiro IDE

```bash
claude setup-ide
kiro --install-extension anthropic.claude-code
```

### Connect Terminal to VS Code

1. Open VS Code in your project
2. In a separate terminal, start `claude`
3. Run `/ide` in the session
4. Confirm connection

---

## Project Memory: CLAUDE.md

### Project-level (per-repo)

```
/init
```
Generates a starter `CLAUDE.md` at the repo root with build commands, conventions, etc.

### Global (cross-project)

Place at `~/.claude/CLAUDE.md` for Amazon-specific patterns and personal conventions.

### Importing AGENTS.md

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Bridge with:
```markdown
@AGENTS.md
```

### Global Rules

Place Amazon-specific steering docs under `~/.claude/rules/*.md`.

---

## AgentSpaces (Browser-Based)

Run Claude Code with zero local setup at [agentspaces.amazon.dev](https://agentspaces.amazon.dev):
1. Pick Claude Code from the apps bar
2. Choose a blueprint or quick-launch empty workspace
3. Code in the browser terminal

---

## Permissions & Tool Approvals

### Reduce Permission Prompts

```
/fewer-permission-prompts
```

### Pre-approve Commands in settings.json

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)"
    ]
  }
}
```

### Auto Mode

```json
{
  "permissions": {
    "defaultMode": "auto"
  }
}
```

### Skip All Prompts (sandboxes only)

```bash
claude --dangerously-skip-permissions
```

---

## Claude Code vs Kiro CLI

| Feature | Claude Code | Kiro CLI |
|---------|-------------|----------|
| **Maker** | Anthropic | AWS / ASBX |
| **Auth** | Bedrock (via Toolbox wrapper) | Midway + IAM |
| **Config dir** | `~/.claude/` | `~/.kiro/` |
| **Extensibility** | Pure composition (plugins layer) | Isolated agents (per-agent system prompt, tools) |
| **MCP** | First-class, mature | Auto-wires Amazon-internal MCPs |
| **Skills format** | Same as Kiro (SKILL.md + frontmatter) | Same |
| **IDE** | VS Code extension, JetBrains, terminal | Kiro IDE (VS Code fork) + CLI |
| **Install** | `toolbox install claude-code` | `toolbox install kiro` |

**Key architectural difference** (per @jahood): Kiro CLI isolates each custom agent with its own dedicated system prompt, MCP tools, skills, and hooks. Claude Code uses pure composition — plugins layer on top, subagents inherit global MCP tools and skills.

---

## ASBX (Amazon Software Builder Experience)

ASBX is the org that maintains:
- **Builder Toolbox** — the distribution mechanism for Claude Code
- **Builder MCP** — the MCP server providing internal tool access
- **AIM** — AI Integration Manager for plugins, agents, skills
- **AgentSpaces** — browser-based AI coding environments
- **Kiro CLI** — the alternative agentic CLI

The Claude Code wrapper is maintained by ASBX team: Developer Tools / IDEs / Cecelia.

---

## Key Community Resources (per @jahood and GenAI Power Users)

- **Slack:** `#claude-code-internal-interest` — primary support channel
- **Slack:** `#amazon-builder-genai-power-users` — power user community
- **Sage:** [Claude-Code tag](https://sage.amazon.dev/tags/Claude-Code)
- **AIM Power User Plugin:** `aim plugins install AIPowerUserCapabilities` — 150+ Agent SOPs, 15+ skills, 6 ready-to-use agents
- **Kiro2Claude Migration Tool:** `aim agents install Kiro2Claude --version-set Kiro2ClaudeTool/development` — migrates Kiro setups to CC
- **AI Registry:** [ai-registry.amazon.dev](https://ai-registry.amazon.dev) — discover available plugins

### @jahood Key Contributions

- Published the AIPowerUserCapabilities AIM package (150+ Agent SOPs, 15+ skills)
- Authored PDD (Prompt-Driven Development) methodology and tutorial videos
- Clarified Claude Code vs Kiro CLI architectural differences
- Confirmed builder-mcp tool response bloat issues and planned fixes
- Shared AgentSpaces vision for ASBX
- Noted that ASBX and Kiro teams are collaborating on CAZ integration

---

## Updating & Troubleshooting

### Update

```bash
toolbox update claude-code
toolbox update aim
```

### Clean Reinstall

```bash
cp ~/.claude/settings.json ~/claude-settings.backup.json 2>/dev/null
cp -R ~/.claude/rules ~/claude-rules.backup 2>/dev/null
rm -rf ~/.claude ~/.claude.json
toolbox install claude-code
```

### Common Issues

| Symptom | Fix |
|---------|-----|
| "Unable to find a registry containing these tools" | No access — L4+ only |
| "Could not load credentials from any provider" | `toolbox update claude-code` |
| `/mcp` shows no servers | `aim mcp install builder-mcp` in second terminal |
| `/model` shows wrong model | Remove `ANTHROPIC_MODEL` from shell profile |
| "Expected 'thinking' or 'redacted_thinking'" | Stale beta config — clean reinstall |
| Can't access `w.amazon.com` | Use Builder MCP's search tools instead |
| AGENTS.md ignored | Add `@AGENTS.md` to your CLAUDE.md |

---

## Usage Policy

Claude Code can be used for **any purpose** in the ordinary course of work (writing code, building tools, fixing bugs). It **cannot** be used for the explicit purpose of developing/training/improving foundation models. Contact your business line lawyer for edge cases.

---

## Sources

- [Claude Code — BuilderHub](https://docs.hub.amazon.dev/claude-code) — accessed 2026-06-17
- [Installing Claude Code — BuilderHub](https://docs.hub.amazon.dev/docs/claude-code/user-guide/getting-started-cli/) — accessed 2026-06-17
- [IDE Integration — BuilderHub](https://docs.hub.amazon.dev/docs/claude-code/user-guide/getting-started-ide/) — accessed 2026-06-17
- [Using Claude Code — BuilderHub](https://docs.hub.amazon.dev/docs/claude-code/user-guide/howto/) — accessed 2026-06-17
- [Ernie's Guide to Claude Code](https://w.amazon.com/bin/view/Users/ernii/ClaudeCode/) — accessed 2026-06-17
- [Claude Code vs Kiro CLI](https://w.amazon.com/bin/view/Stores_Finance_Productivity/Tools/Claude_Code_vs_Kiro_CLI/) — accessed 2026-06-17
- [Claude Code Setup — Search Team](https://w.amazon.com/bin/view/Search/Docs/ClaudeCode) — accessed 2026-06-17
- [Claude Code Setup — CloudEndure/Cirrus](https://w.amazon.com/bin/view/AWS/CloudEndure/Cirrus/ClaudeCode) — accessed 2026-06-17
- [VS Code + Claude Code Installation Guide](https://w.amazon.com/bin/view/Users/yanghuxx/Quip/VSCodeClaudeCodeInstallationGuide/) — accessed 2026-06-17
- [Claude-code-bedrock-setup — AWS Learning Services](https://w.amazon.com/bin/view/AWS_Learning_Services/AWSTCPD_TeamFrazzle/Opex/wikis/KiroLearn/Development/Tools/Claude-code-bedrock-setup) — accessed 2026-06-17
- [Amazon Quick Desktop Setup — TNC](https://w.amazon.com/bin/view/TNC/AmazonQuickDesktopSetup) — accessed 2026-06-17
- [2026-05 GenAI Power User Monthly Newsletter](https://w.amazon.com/bin/view/GenAIPowerUsers/Newsletters/Monthly/2026-05/) — accessed 2026-06-17
- [2026-05-08 GenAI Power User Weekly Newsletter](https://w.amazon.com/bin/view/GenAIPowerUsers/Newsletters/Weekly/2026-05-08/) — accessed 2026-06-17
- [2026-01 GenAI Power User Monthly Newsletter](https://w.amazon.com/bin/view/GenAIPowerUsers/Newsletters/Monthly/2026-01/) — accessed 2026-06-17
- [ASBX Tools Directory — BuilderHub](https://docs.hub.amazon.dev/docs/tools/) — accessed 2026-06-17
