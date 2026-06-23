# Claude Code Project-Level Skills: .claude/skills/ Directory

## Executive Summary

Claude Code supports **project-level skills** checked directly into your repository under `.claude/skills/`. This is distinct from user-level skills (`~/.claude/skills/`) and AIM plugin skills. Project skills are shared with your team via git and auto-discovered when working in that project directory.

**Key discovery**: Claude Code auto-discovers skills from exactly these locations:
1. `~/.claude/skills/` — user-level (personal, all projects)
2. `.claude/skills/` — project-level (checked into the repo, shared via git)

Over **1,000 repos** on code.amazon.com already have `.claude/skills/` committed.

---

## 1. Skill Discovery: Project vs User vs Plugin

### Claude Code Native Discovery

Claude Code auto-discovers skills from two locations (confirmed in multiple sources):

```
~/.claude/skills/*/SKILL.md     — User-level (personal, all projects)
<project>/.claude/skills/*/SKILL.md  — Project-level (repo-committed, team-shared)
```

From the `AIAgentsManagement` repo:
> "Claude Code only auto-discovers slash commands and skills in `~/.claude/commands/`, `~/.claude/skills/`, and the workspace `.claude/commands/` + `.claude/skills/` — not from arbitrary package locations referenced in CLAUDE.md."

### builder-mcp Discovery (When Using AIM/Kiro)

builder-mcp loads skills with this precedence (first occurrence of a name wins):

1. **`--skill-paths` (if set) OR global `~/.aim/skills/` (if not)** — mutually exclusive
2. **Project-local, always loaded if present:** `wasabi-toolbag/skills/`, `.claude/skills/`
3. **User skills, always loaded if present:** `~/.builder-mcp/skills/`

### Kiro/Kimi CLI Discovery

For Kiro-based agents, skill loading is layered (built-in → user → project):

**User level** (by priority):
- `~/.config/agents/skills/` (recommended)
- `~/.kimi/skills/`
- `~/.claude/skills/`

**Project level**:
- `.agents/skills/`

### AIM Plugin Skills

AIM skills install to `~/.aim/skills/{SkillSetName}/{skill-name}/SKILL.md` and require registration in the agent specification (`agents/*.agent-spec.json`):

```json
{
  "dependencies": {
    "skills": {
      "skillNames": ["my-skill"]
    }
  }
}
```

### Aki (Internal Tool) Discovery with Conflict Resolution

Priority order: `user_preference > workspace > profile > aim`

| Location | Path | Purpose |
|----------|------|---------|
| User Preference (highest) | `~/.aki/user_preference/{profile}/skills/` | Personal overrides |
| Workspace | `{workspace}/.agent/skills/` | Project-specific, git-tracked |
| Profile | `~/.aki/profiles_v2/{profile}/skills/` | Profile defaults |
| AIM (lowest) | `~/.aim/skills/{SkillSetName}/` | Globally installed |

---

## 2. SKILL.md Format

### Minimal (Required Fields Only)

```yaml
---
name: my-skill
description: Brief description of what the skill does
---

# My Skill

## Instructions

Step-by-step guidance for the task...
```

### Full Format (With Optional Fields)

```yaml
---
name: my-skill
description: Brief description of what the skill does. Use when [specific triggers].
compatibility: Works with Python 3.12+, requires pytest
metadata:
  version: "1.0.0"
  tags: [category, technology]
  author: your-org
  resources:
    - scripts/helper.py
    - scripts/run.sh
    - references/guide.md
    - references/api.md
  custom_field: custom_value
---

# My Skill

## Instructions

Step-by-step guidance for the task...

## Examples

Concrete examples with code/commands...
```

### Claude Code-Specific Format (with triggers)

Some teams add a `triggers` field for keyword matching:

```yaml
---
name: my-skill
description: One-line summary of what this skill does
triggers:
  - keyword1
  - keyword2
---

# My Skill

## Purpose
What this skill helps with and when it activates.

## Workflow
1. Step one
2. Step two

## Reference
Any tables, commands, or domain knowledge.
```

### Required Fields

| Field | Constraints |
|-------|-------------|
| `name` | Lowercase letters, numbers, hyphens only. Max 64 characters. |
| `description` | Clear explanation of what the skill does and when to use it. Max 1024 characters. |

### Optional Fields

| Field | Purpose |
|-------|---------|
| `compatibility` | Usage guidelines, version requirements |
| `metadata.version` | Semantic version |
| `metadata.tags` | Categorization tags |
| `metadata.author` | Author or org |
| `metadata.resources` | Relative paths to supporting files |
| `triggers` | Keywords that trigger skill activation |

---

## 3. Skill Directory Structure

```
.claude/skills/
├── my-skill/
│   ├── SKILL.md           # Required: main instructions
│   ├── reference.md       # Optional: detailed docs
│   ├── examples.md        # Optional: usage examples
│   ├── scripts/           # Optional: helper scripts
│   │   └── helper.py
│   ├── references/        # Optional: reference materials
│   │   ├── guide.md
│   │   └── api.md
│   ├── templates/         # Optional: output templates
│   │   └── template.txt
│   └── assets/            # Optional: files for output (not loaded to context)
│       └── icon.png
└── another-skill/
    └── SKILL.md
```

### Progressive Disclosure

Skills use a three-level loading system:
1. **Metadata (name + description)** — Always in context (~100 words)
2. **SKILL.md body** — Loaded when skill triggers (<5k words recommended)
3. **Bundled resources** — Loaded as needed by the agent

### When to Split Files

Split into separate files when:
- `SKILL.md` exceeds 100 lines
- Content has distinct domains
- Advanced features are rarely needed

---

## 4. How to Set Up Project-Level Skills

### Step 1: Create the skill directory

```bash
mkdir -p .claude/skills/my-skill
```

### Step 2: Write SKILL.md

```bash
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Project-specific workflow for [your use case]
---

# My Skill

## Instructions

1. Step one
2. Step two
EOF
```

### Step 3: Add to git

```bash
git add .claude/skills/
git commit -m "Add project-level Claude Code skill: my-skill"
git push
```

### Step 4: Use it

Start a new Claude Code session in the project. The skill auto-discovers from the `name` and `description` in SKILL.md frontmatter. The agent will autonomously invoke it when your request matches the skill's description.

---

## 5. Project vs Plugin Skills: Key Differences

| Aspect | Project Skills (`.claude/skills/`) | AIM Plugin Skills |
|--------|--------------------------------------|-------------------|
| Location | Checked into repo | Installed via `aim` CLI |
| Discovery | Auto-discovered by Claude Code | Registered in agent-spec.json |
| Sharing | Via git (team gets them on clone) | Via AIM package manager |
| Scope | Single project | Cross-project |
| Loading | Progressive disclosure (main agent) | Preloaded for sub-agents |
| Registration | None needed | Must declare in `dependencies.skills` |

### Plugin Behavior in Claude Code

From BuilderHub docs:
> **Main agent (default Claude Code session):** Skills are discovered automatically via progressive loading — descriptions at startup, full content on demand when invoked.
>
> **Sub-agents (skills: frontmatter):** When a sub-agent lists skills in its `skills:` field, the full skill content is preloaded into the sub-agent's context at startup. Sub-agents do not inherit skills from the parent; they only get what's explicitly listed.

---

## 6. Team Examples of .claude/skills/ in Repos

Over 1,000 repos have `.claude/skills/` committed. Notable examples:

| Repository | Skills | Description |
|-----------|--------|-------------|
| `ACTCodeReviewerAgent` | `review-cr`, `review-pending` | Automated code review with parallel agent spawning |
| `AGIEmergeSlime` | `skill-creator` | Meta-skill for creating skills (18KB!) |
| `AFSCoreAgent` | `falcon-ssm-tunnel`, `fenix-log-downloader`, `aws-accounts` | AWS operational skills |
| `AWSDS3ModelSmithHandoffAgent` | `consistency-test`, `pipeline-test`, `debug-session`, `handoff-e2e` | ML pipeline testing |
| `AmazonBedrockForkliftDataplaneAgentSteering` | `model-test`, `cloudwatch`, `escrow` | Bedrock model testing |
| `AmazonForgeAIAgent` | `skill-writer` | Skill authoring guidelines |
| `AmazonResearchSuite` | Multiple shared skills | Research workflow automation |
| `AGIRAIAgentEvalExp` | `onboard-audit`, `onboard-from-github` | Agent evaluation benchmarks |
| `ABPurchasePreferencesService` | `abpps-dev-loop`, `unit-testing` | Dev workflow + Java testing |
| `ATXDotNetAgentRuntimeTests` | `debug-tod-run`, `cloudwatch-log-analysis` | .NET agent debugging |
| `A9VSTangoOncallAgent` | `skill-management` | Oncall agent meta-skill |
| `AWSFlinkAgentSkills` | Multiple MSF skills | Flink observability |
| `FOAA/BIE` (team wiki) | `wiki-project`, `send-cr`, `doc-skill` | Team automation |

### Complex Example: ACTCodeReviewerAgent

This repo demonstrates advanced project skills with:
- Multi-phase workflows (34KB SKILL.md)
- Python extraction scripts (`extract.py` — 50KB)
- Prompt templates (`prompts/semantic-reviewer.md`)
- Reference materials (`references/comment-format.md`)
- Skill-to-skill references (review-pending → review-cr)

### Cross-CLI Portability: AmazonForgeAIAgent

This repo shows skills authored once in Claude format and generated to other CLIs:
```
.claude/skills/<skill-name>/SKILL.md  ← source of truth
.agents/   ← generated for Codex
.cursor/   ← generated for Cursor
```

---

## 7. Best Practices

### From Internal Documentation

1. **Keep SKILL.md under 100 lines** — Split into reference files beyond this
2. **Description includes triggers** — e.g., "Use when deploying to production..."
3. **No time-sensitive info** — Skills should be evergreen
4. **One level deep references** — Don't nest reference files
5. **Verb-led naming** — `deploy-service`, `review-code`, not `service-deployment`
6. **Include concrete examples** — The agent works better with examples
7. **Large reference files** — Include grep patterns in SKILL.md so agent can search

### Symlink Pattern for Shared Skills

Many teams symlink from a shared package into their workspace:

```bash
# Link a shared skill repo into your project
ln -s /path/to/SharedSkillsRepo/skills/my-skill .claude/skills/my-skill

# Or from a Brazil package
cd ~/workplace/<feature-id>/.claude
ln -sf ../src/SharedSkillsPackage/skills skills
```

### Install Script Pattern

From `AWSFlinkAgentSkills`:
```bash
# Install to current project's .claude/skills/
cd claude
bash install.sh install --local

# Install to user-level
bash install.sh install --global
```

---

## 8. Context Layers Reference

Full Claude Code context hierarchy:

```
~/.claude/rules/*.md              — Global rules (always loaded, all projects)
<project>/.claude/rules/          — Project rules (always loaded in that project)
<project>/CLAUDE.md               — Project instructions
.claude/settings.json             — Permissions, MCP servers, hooks
.claude/skills/*/SKILL.md         — On-demand skills (loaded by keyword trigger)
~/.claude/projects/<path>/memory/ — Auto memory (persists across sessions)
```

---

## Sources

- [BuilderHub AIM Skills Documentation](https://docs.hub.amazon.dev/aim/user-guide/concepts/skills) — accessed 2026-06-18
- [BuilderHub Plugin Behavior: Claude Code](https://docs.hub.amazon.dev/aim/user-guide/concepts/plugins-claude-code) — accessed 2026-06-18
- [AWS Avengers Claude Code Setup Wiki](https://w.amazon.com/bin/view/AWS/Avengers/Resources/Guides/ClaudeCodeSetup) — accessed 2026-06-18
- [AWS Avengers Claude Code Configuration Wiki](https://w.amazon.com/bin/view/AWS/Avengers/Resources/Guides/ClaudeCode/Configuration) — accessed 2026-06-18
- [FOAA BIE Claude Skills Wiki](https://w.amazon.com/bin/view/FOAA/BIE/ClaudeSkills) — accessed 2026-06-18
- [Aki Skills System Wiki](https://w.amazon.com/bin/view/Aki/UserManual/features/skills) — accessed 2026-06-18
- [Mtterada Claude Code Migration Wiki](https://w.amazon.com/bin/view/Mtterada_personal_page/Claude_Code) — accessed 2026-06-18
- [AGIEmergeSlime skill-creator SKILL.md](https://code.amazon.com/packages/AGIEmergeSlime/blobs/mainline/--/.claude/skills/skill-creator/SKILL.md) — accessed 2026-06-18
- [AIMSkillDevelopment aim-reference.md](https://code.amazon.com/packages/AIMSkillDevelopment/blobs/mainline/--/skills/aim-skill-development/references/aim-reference.md) — accessed 2026-06-18
- [AIAgentsManagement create-feenix-workspace SKILL.md](https://code.amazon.com/packages/AIAgentsManagement/blobs/mainline/--/skills/create-feenix-workspace/SKILL.md) — accessed 2026-06-18
- [AgiNeuralyzerPromptBook kiro-skills-guide.md](https://code.amazon.com/packages/AgiNeuralyzerPromptBook/blobs/mainline/--/docs/kiro-skills-guide.md) — accessed 2026-06-18
