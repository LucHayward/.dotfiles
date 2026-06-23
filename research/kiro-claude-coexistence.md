# .kiro and .claude Coexistence in the Same Repository

## Executive Summary

There is **no single canonical "coexistence" guide**, but the Amazon internal community has converged on clear patterns. The dominant approach is **AGENTS.md as the single source of truth**, with thin per-tool adapters (`CLAUDE.md` for Claude Code, `.kiro/steering/` for Kiro). Several teams have documented this, and an automated tool (`Kiro2Claude`) exists to bridge the two. Key findings:

1. **AGENTS.md is the universal bridge** — both Kiro CLI and Claude Code read it (with minor wiring)
2. **Symlink approach exists** — `ln -s AGENTS.md CLAUDE.md` is documented by B2B Invoicing/Kraken team
3. **Kiro2Claude tool** — automated migration/coexistence tool that converts `.kiro/steering` → `CLAUDE.md` imports
4. **`sync_to_claude_code.sh`** — rksaka@ built a script that generates `CLAUDE.md` from 42 steering files
5. **AIM package pattern** — single package ships to both tools via `aim agents install` / `aim plugins install`

---

## Pattern 1: AGENTS.md as Single Source of Truth

The community consensus (documented by AIOLabs, SilverFoxes, B2B Invoicing, dwivepus, and wberntso) is:

```
my-package/
├── AGENTS.md                    # THE source of truth (tool-agnostic)
├── CLAUDE.md                    # One-line: @AGENTS.md (or symlink)
├── .kiro/
│   └── steering/
│       └── codebase-summary.md  # inclusion: always, with #[[file:AGENTS.md]]
└── ...
```

### How each tool reads it:

| Tool | What it auto-reads | How to bridge |
|------|-------------------|---------------|
| **Kiro IDE** | `.kiro/steering/*.md` | Create `.kiro/steering/codebase-summary.md` with `#[[file:AGENTS.md]]` |
| **Kiro CLI** | `.kiro/steering/*.md` + `AGENTS.md` natively | AGENTS.md auto-discovered |
| **Claude Code** | `CLAUDE.md` only | Add `@AGENTS.md` line inside `CLAUDE.md` |
| **Cline** | Workspace files as context | Reads `AGENTS.md` directly |
| **Codex** | Expected to follow `AGENTS.md` | Native support expected |

### The `@AGENTS.md` import (Claude Code)

Claude Code's import syntax is a literal `@AGENTS.md` line inside `CLAUDE.md`:

```markdown
# CLAUDE.md

AI context for this package lives in AGENTS.md (the tool-agnostic single source).

@AGENTS.md
```

### The Kiro steering adapter

```markdown
---
inclusion: always
---

#[[file:AGENTS.md]]
```

This goes in `.kiro/steering/codebase-summary.md` and ensures Kiro sessions auto-load the same content.

---

## Pattern 2: Symlink Approach

Documented by B2B Invoicing/Kraken team (ybadinen@):

```bash
ln -s AGENTS.md CLAUDE.md
```

This is the simplest approach. Both files resolve to the same content. The directory structure:

```
my-package/
├── AGENTS.md                    # Actual file
├── CLAUDE.md → AGENTS.md        # Symlink
└── AUTOSDE.yaml                 # Wire to code review enforcement
```

**Caveats:**
- Git stores symlinks; Windows may not handle them correctly
- Claude Code's `@import` syntax won't work inside a symlink target
- Some teams prefer the `@AGENTS.md` import pattern for flexibility (allows CLAUDE.md-specific additions)

---

## Pattern 3: Auto-Generation Tooling

### 3a. Kiro2Claude Tool (dwivepus@)

**Package:** `code.amazon.com/packages/Kiro2Claude`

A full migration/coexistence tool with multiple modes:

```bash
# Install
aim agents install Kiro2Claude --version-set Kiro2ClaudeTool/development

# Full migration (non-destructive, both tools coexist after)
kiro-cli chat --agent kiro2claude "migrate"

# Convert steering files only (current directory)
kiro-cli chat --agent kiro2claude "steering"

# Undo everything
kiro-cli chat --agent kiro2claude "undo"
```

**What the `steering` mode does:**
1. Reads `AGENTS.md` in the current directory
2. Creates `CLAUDE.md` alongside it with `@AGENTS.md` import
3. For `.kiro/steering/*.md` files: merges into a single `CLAUDE.md` reference
4. **Non-destructive** — original files are never modified
5. Both tools read from the same source afterward

**Key design principle from the tool:**
> "Create CLAUDE.md that references the existing AGENTS.md using import syntax. This way both kiro-cli and Claude Code read from the same source — no duplication, no drift. Do NOT copy the content — just reference it."

### 3b. sync_to_claude_code.sh (rksaka@)

A shell script that generates `CLAUDE.md` from all `.kiro/steering/` files:

```bash
./sync_to_claude_code.sh /path/to/project
```

**What it does:**
- Scans all 42 steering files in `.kiro/steering/`
- Generates a consolidated `CLAUDE.md` (content copy, not reference)
- Coverage: Kiro = 100% automated enforcement; Claude Code = ~45% (rules loaded, no hook automation)

**Limitations noted by the author:**
- Claude Code lacks Kiro hooks (22 event-driven hooks not portable)
- Agent isolation not supported in Claude Code plugins
- Pattern auto-lookup, file references, post-task build/test — all Kiro-only

### 3c. AAIBuilderKit `claude-setup` (SessionStart hook)

A `SessionStart` hook that auto-generates `CLAUDE.md` files in Brazil workspaces:

```
- Package directories get CLAUDE.md with @AGENTS.md and @spec/agent.md references
- Workspace and src directories get CLAUDE.md with instructions for Claude to read each package's context
- Package-level CLAUDE.md files are never overwritten once created
- Workspace/src-level files are updated to include newly added packages
```

### 3d. Soyuz Codebase Summary SOP (ABAcquisitionAgents)

An AIM agent SOP that wraps `@agent-sop:codebase-summary` to make packages AI-ready for **both** tools simultaneously:

```bash
# Generates AGENTS.md + wires it to both Claude Code and Kiro
/builder-mcp:codebase-summary
```

**Non-negotiable principles from this SOP:**
1. **Single source of truth** — `AGENTS.md` holds the content. Adapters only reference it
2. **Tool- and model-agnostic** — Never write tool names into `AGENTS.md`
3. **Idempotent** — Re-running won't create duplicates
4. **Surgical** — Touch only the files the SOP defines

---

## Pattern 4: AIM Package (Ship Skills to Both)

Documented by wberntso@ (Stores Finance):

```
WberntsoAICapabilities/
├── skills/           # SKILL.md with frontmatter (same format for both tools)
├── agents/           # .agent-spec.json (AIM format)
├── agent-sops/       # Multi-step procedures
└── context/          # Auto-loaded context
```

Both tools install from the same source:
```bash
# For Kiro
aim agents install WberntsoAICapabilities

# For Claude Code
aim plugins install WberntsoAICapabilities
```

**Key insight:** The skill format is identical between both tools (Markdown + YAML frontmatter). One package, one `brazil-build`, one `git push` — both harnesses get the update.

---

## Pattern 5: Shared Memory Layer (dwivepus@)

For cross-tool personal knowledge:

```
~/notes/                         # Plain markdown files you own
├── methodology-guidelines.md
├── writing-voice.md
└── account-*.md
```

**Wire into Claude Code** (`~/.claude/CLAUDE.md`):
```markdown
## Standing notes
I keep cross-project knowledge in `~/notes/`. Read files there when relevant.
```

**Wire into Kiro** (`~/.kiro/steering/notes.md`):
```markdown
---
inclusion: always
---
## Standing notes
Cross-project knowledge in `~/notes/`. Read these when relevant.
```

---

## The 150-Line Rule

From the SilverFoxes AI-Native Practices guide (Tulio Braga):

| Budget | Slots | Notes |
|--------|-------|-------|
| Total reliable instruction capacity | 150–200 | Before degradation becomes severe |
| System prompt tax (tool internals) | 50 | Claude Code, Kiro, Codex consume these |
| **Your steering file budget** | **100–150** | What remains for AGENTS.md / CLAUDE.md / steering |

**Quick self-check:**
```bash
wc -l AGENTS.md .kiro/steering/*.md CLAUDE.md 2>/dev/null
# If total > 150: time to prune
```

**Critical finding:** Auto-generated context files (`/init`, `claude init`) showed **−3% task success, +20% cost** vs. no file at all. Only human-written, minimal context files help.

---

## Comparison Table: File Locations

| Concept | Kiro CLI/IDE | Claude Code |
|---------|-------------|-------------|
| Project instructions | `.kiro/steering/*.md` | `CLAUDE.md` + `.claude/rules/*.md` |
| Global instructions | `~/.kiro/steering/` | `~/.claude/CLAUDE.md` |
| Conditional loading | `paths:` frontmatter | Nested `CLAUDE.md` in subdirs; `paths:` in rules |
| Generate instructions | Manual / Spec Studio | `/init` auto-generates |
| Skills | `~/.kiro/skills/` | `~/.claude/skills/` (same format) |
| Agents | `~/.kiro/agents/*.json` | `~/.claude/agents/*.md` |
| MCP config | `~/.kiro/settings/mcp.json` | `~/.claude.json` |

---

## Specific User Wiki Pages

### dwivepus@ (AIsquared Program)
- **[Guide: Migrating from Kiro CLI to Claude Code](https://w.amazon.com/bin/view/Users/dwivepus/AIsquared/KiroToClaudeCode/)** — The most comprehensive migration guide. Documents the Kiro2Claude tool, manual path, and the "it's not really a migration" philosophy.
- **[Guide: Kiro CLI vs Claude Code — Deep Dive](https://w.amazon.com/bin/view/Users/dwivepus/AIsquared/KiroVsClaudeCode/)** — Includes the shared memory recipe (AGENTS.md + ~/notes/) pattern.

### ernii@ (Ernie's Guide to MCP)
- **[Ernie's Guide to MCP](https://w.amazon.com/bin/view/Users/ernii/MCP/)** — Covers MCP server setup for Kiro CLI, Claude Code, Wasabi, Cline, Cursor, and Q. MCP wiring is the same across tools (builder-mcp works for both). Does not specifically cover .kiro/.claude coexistence but documents how MCP servers are shared across all tools.

### jahood@ (referenced in AIOLabs guide)
- Referenced as author of [PDD (Prompt-Driven Development)](https://w.amazon.com/bin/view/JahoodBlog/2026/02-02-pdd-video-series) which is the shared SOP methodology used by both tools via builder-mcp slash commands.
- No specific .kiro/.claude coexistence wiki page found under their user space.

---

## Recommended Approach for a New Repo

Based on the community patterns:

```bash
# 1. Create AGENTS.md as single source of truth
cat > AGENTS.md << 'EOF'
# MyPackage

## Build & Test
- Build: `brazil-build`
- Test: `brazil-build test`

## Conventions
- [your rules here]

## Do NOT
- [hard constraints]
EOF

# 2. Wire Claude Code (one-line import)
echo '@AGENTS.md' > CLAUDE.md

# 3. Wire Kiro
mkdir -p .kiro/steering
cat > .kiro/steering/codebase-summary.md << 'EOF'
---
inclusion: always
---

#[[file:AGENTS.md]]
EOF

# 4. (Optional) Symlink approach instead of step 2
# ln -s AGENTS.md CLAUDE.md
```

---

## Sources

- [AIOLabs — Claude Code for Kiro CLI Users](https://w.amazon.com/bin/view/AIOLabs/Guides/ClaudeCodeForKiroUsers) — accessed 2026-06-18
- [dwivepus — Migrating from Kiro CLI to Claude Code](https://w.amazon.com/bin/view/Users/dwivepus/AIsquared/KiroToClaudeCode/) — accessed 2026-06-18
- [dwivepus — Kiro CLI vs Claude Code Deep Dive](https://w.amazon.com/bin/view/Users/dwivepus/AIsquared/KiroVsClaudeCode/) — accessed 2026-06-18
- [SilverFoxes — Steering Files & AGENTS.md](https://w.amazon.com/bin/view/IntechLatam/FBA/SFX/SilverFoxes/AINativePractices/HandsOn/SteeringFiles) — accessed 2026-06-18
- [B2B Invoicing — Guide to Maintaining Steering Files](https://w.amazon.com/bin/view/Amazon_Business/B2BInvoicing/Kraken/SteeringFilesGuide/) — accessed 2026-06-18
- [Stores Finance — Claude Code vs Kiro CLI](https://w.amazon.com/bin/view/Stores_Finance_Productivity/Tools/Claude_Code_vs_Kiro_CLI) — accessed 2026-06-18
- [AWS CloudEndure — Claude Code Setup (symlink pattern)](https://w.amazon.com/bin/view/AWS/CloudEndure/Cirrus/ClaudeCode) — accessed 2026-06-18
- [rksaka — Compliance AI Framework + sync_to_claude_code.sh](https://w.amazon.com/bin/view/Users/rksaka/AIFramework/GetStarted/ClaudeCode/) — accessed 2026-06-18
- [Kiro2Claude tool](https://code.amazon.com/packages/Kiro2Claude/trees/mainline) — accessed 2026-06-18
- [ABAcquisitionAgents — Soyuz Codebase Summary SOP](https://code.amazon.com/packages/ABAcquisitionAgents/blobs/mainline/--/agent-sops/soyuz-codebase-summary/soyuz-codebase-summary.sop.md) — accessed 2026-06-18
- [BuilderHub — Kiro Steering](https://docs.hub.amazon.dev/kiro/user-guide/howto-steering) — accessed 2026-06-18
- [BuilderHub — Claude Code](https://docs.hub.amazon.dev/claude-code) — accessed 2026-06-18
- [ernii — Ernie's Guide to MCP](https://w.amazon.com/bin/view/Users/ernii/MCP/) — accessed 2026-06-18
- [A3UWikiCDK — CLAUDE.md referencing AGENTS.md](https://code.amazon.com/packages/A3UWikiCDK/blobs/mainline/--/CLAUDE.md) — accessed 2026-06-18
