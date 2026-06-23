# Cross-Tool Compatibility Report: Kiro CLI ↔ Claude Code

## Executive Summary

Your dotfiles already install both `kiro-cli` and `claude-code` via Toolbox, but only configure Kiro (AIM agents install, LSPs, AGENTS.md conventions). Claude Code is installed but unconfigured — no plugins, no CLAUDE.md, no IDE integration. Your team repos (e.g. FoundryWorkflows) have `.kiro/` directories that are invisible to Claude Code users.

This report covers:
1. What to add to your dotfiles install scripts for Claude Code parity
2. How to structure team repos for cross-tool compatibility

---

## Part 1: Dotfiles Install Script Changes

### Current State

| Step | Kiro CLI | Claude Code |
|------|----------|-------------|
| Toolbox install | ✅ `kiro-cli` | ✅ `claude-code` |
| AIM agents/plugins | ✅ `aim agents install AIPowerUserCapabilities` | ❌ Missing |
| IDE integration | — | ❌ `claude setup-ide` not run |
| Global config | `AGENTS.md` conventions baked into AIM agent | ❌ No `~/.claude/CLAUDE.md` |
| LSPs | ✅ typescript-language-server, pyright, jdtls | N/A (CC manages its own) |
| Builder MCP | ✅ (via AIM agent) | ✅ Auto-configured on first launch |

### Recommended Changes to `mac_install.sh`

Add a Claude Code configuration section after the existing AIM agents install:

```bash
# ================================
# Configure Claude Code (plugins + IDE + global rules)
# ================================
if ask_confirmation "Configure Claude Code (plugins, IDE integration, global CLAUDE.md)"; then
	# Install plugins (Claude Code equivalent of aim agents install)
	aim plugins install AIPowerUserCapabilities

	# IDE integration (configures VS Code/Kiro extension settings)
	claude setup-ide

	# Global CLAUDE.md (persistent context across all projects)
	mkdir -p ~/.claude
	ln -sf ~/.dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

	echo "✓ Claude Code configured"
	echo "  Verify with: claude → /plugins → /mcp"
fi
```

### Recommended Changes to `linux_install.sh`

Add after the existing `axe init builder-tools` section:

```bash
	# Configure Claude Code (if installed)
	if command -v claude &>/dev/null; then
		aim plugins install AIPowerUserCapabilities
		mkdir -p ~/.claude
		ln -sf ~/.dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
	fi
```

### New File: `claude/CLAUDE.md`

Create a tracked global CLAUDE.md in your dotfiles:

```markdown
# Global Claude Code Context

## Amazon Development

- Build system: Brazil (brazil-build, brazil-recursive-cmd)
- Code reviews: CRUX (cr CLI)
- Auth: Midway (mwinit), credentials via ada CLI
- Deployment: Apollo
- Use Builder MCP tools for internal search, code search, and ticketing

## Conventions

- Follow conventional commits (feat/fix/docs/refactor/test/chore)
- Never push directly to mainline
- Run build + tests before creating CRs
- Use feature flags for backwards-incompatible changes in workflow services

## Git Safety

- Never force push or rewrite pushed history
- Prefer new commits over amend for pushed work
- Squash via merge --squash when merging feature branches

@~/.dotfiles/AGENTS.md
```

The `@~/.dotfiles/AGENTS.md` line imports your existing AGENTS.md conventions directly, so you maintain one source of truth.

### Updated Validation Section

Add Claude Code checks to the existing validation block in `mac_install.sh`:

```bash
echo ""
echo "--- AI Tools ---"
for cmd in kiro claude aim; do
    if command -v $cmd &>/dev/null; then
        echo "	✓ $cmd"
    else
        echo "	✗ $cmd NOT FOUND"
        ((failed++))
    fi
done
# Check AIM plugins are installed
if [[ -d "$HOME/.aim/cc-plugins" ]] && ls ~/.aim/cc-plugins/*/. &>/dev/null 2>&1; then
    echo "	✓ Claude Code plugins installed"
else
    echo "	⚠ No Claude Code plugins found (run: aim plugins install AIPowerUserCapabilities)"
fi
```

---

## Part 2: Team Repository Recommendations

### Problem Statement

Your team has `.kiro/steering/` and `.kiro/prompts/` in packages (like FoundryWorkflows). Claude Code users get none of this context. They see no architecture docs, no coding standards, no SOPs.

### Recommended Repo Structure (Cross-Tool)

```
MyPackage/
├── AGENTS.md                          # Kiro reads this (via AIM agent context)
├── CLAUDE.md                          # Claude Code reads this (imports from .kiro/)
├── .kiro/
│   ├── steering/
│   │   ├── architecture.md            # Source of truth (inclusion: always)
│   │   ├── coding-standards.md        # Source of truth (inclusion: always)
│   │   └── manual-testing.md          # Source of truth (inclusion: manual)
│   └── prompts/
│       ├── check-swf-compatibility.md # SOP
│       └── investigate-workflow.md    # SOP
└── .claude/
    └── skills/                        # Optional: project-level skills for CC
        └── check-swf-compatibility/
            └── SKILL.md               # Thin wrapper or copy of .kiro/prompts/ content
```

### The Bridge: `CLAUDE.md`

For each repo, add a single file to the root:

```markdown
@.kiro/steering/architecture.md
@.kiro/steering/coding-standards.md
```

That's it. Claude Code's `@` include syntax pulls the Kiro steering docs into context. The `---\ninclusion: always\n---` frontmatter is harmless (Claude Code treats it as markdown text).

For manually-included docs, add them as comments:

```markdown
@.kiro/steering/architecture.md
@.kiro/steering/coding-standards.md

## Additional Context (load on demand)
<!-- For manual testing workflows, see .kiro/steering/manual-testing.md -->
<!-- For SWF compatibility checking, see .kiro/prompts/check-swf-compatibility.md -->
```

### Prompts/SOPs: Options

| Approach | Effort | Compatibility | Maintenance |
|----------|--------|---------------|-------------|
| **A. `@` import in CLAUDE.md** | Minimal | Good enough for context | Zero — uses .kiro/ as source |
| **B. `.claude/skills/` with SKILL.md** | Medium | Full progressive loading in CC | Dual maintenance unless scripted |
| **C. AIM package** | High | Best (both tools via aim install) | Single source, works everywhere |

**Recommendation:** Start with **A** for all repos immediately (5 min per repo). Migrate high-value SOPs to **C** (AIM packages) over time for teams that want slash-command access in both tools.

### Concrete Example: FoundryWorkflows

Add this file:

**`CLAUDE.md`** (repo root):
```markdown
@.kiro/steering/architecture.md
@.kiro/steering/coding-standards.md
```

That gives Claude Code users the same architecture context and coding standards that Kiro users get via steering. The prompts (SOPs) don't auto-load in either tool without explicit invocation, so they're equivalent already.

---

## Part 3: Summary of Actions

### Dotfiles (your personal setup)

| # | Action | File | Effort |
|---|--------|------|--------|
| 1 | Create `claude/CLAUDE.md` in dotfiles | New file | 5 min |
| 2 | Add symlink in `common_install.sh` | One line | 1 min |
| 3 | Add `aim plugins install` section to `mac_install.sh` | ~15 lines | 5 min |
| 4 | Add Claude Code to `linux_install.sh` | ~5 lines | 2 min |
| 5 | Update validation checks | ~10 lines | 3 min |

### Team repos (e.g. FoundryWorkflows)

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 1 | Add `CLAUDE.md` with `@` imports of steering docs | 1 min per repo | All Claude Code users get context |
| 2 | (Optional) Add `.claude/skills/` for key SOPs | 15 min per SOP | Slash-command access in CC |
| 3 | (Long-term) Package team SOPs as AIM package | Hours | Both tools, versioned, shareable |

### Key Principles

1. **`.kiro/steering/` remains source of truth** — never duplicate content
2. **`CLAUDE.md` is a thin import layer** — just `@` references
3. **`aim plugins install` for Claude Code, `aim agents install` for Kiro** — same AIM package, different install commands
4. **Global `~/.claude/CLAUDE.md`** for personal conventions (symlinked from dotfiles)
5. **Don't symlink skills** — use `aim plugins install` for distributed skills, or `.claude/skills/` for project-local ones

---

## Sources

- [BuilderHub: Claude Code User Guide](https://docs.hub.amazon.dev/docs/claude-code/user-guide/howto/) — accessed 2026-06-17
- [BuilderHub: Plugin behavior differences](https://docs.hub.amazon.dev/docs/aim/user-guide/concepts/plugins-claude-code/) — accessed 2026-06-17
- [BuilderHub: Plugins](https://docs.hub.amazon.dev/docs/aim/user-guide/concepts/plugins/) — accessed 2026-06-17
- [BuilderHub: Troubleshooting (AGENTS.md not recognized)](https://docs.hub.amazon.dev/docs/claude-code/user-guide/troubleshooting/) — accessed 2026-06-17
- [Wiki: Guide to Claude Code Plugins (AIM)](https://w.amazon.com/bin/view/Users/dwivepus/AIsquared/ClaudeCode-Plugins/) — accessed 2026-06-17
- [Code: FoundryWorkflows/.kiro/](https://code.amazon.com/packages/FoundryWorkflows/trees/mainline/--/.kiro) — accessed 2026-06-17
