# Mise (formerly RTX) at Amazon — Internal Research

## Executive Summary

**Mise is officially recommended and widely used at Amazon.** It is:

1. **Written by an Amazon engineer** who works on Builder Tools
2. **Included in the official `axe init builder-tools` installer** — the standard developer environment setup
3. **Recommended by ASBX (Amazon Software Builder Experience)** as the tool version manager for Python and Node.js in the Peru dependency model
4. **Integrated into Peru build hosts** already
5. **Has a dedicated Amazon-internal plugin** (`RtxNode`) for installing Amazon-built Node.js binaries

There are **no recommendations against using mise**. On the contrary, the official BuilderHub documentation explicitly recommends **uninstalling asdf** if installed, because it conflicts with mise.

---

## 1. Is Mise Widely Used at Amazon?

### Yes — Strong Adoption Evidence

**Code Repository Usage:**
- 20+ repositories found with `mise.toml` configuration files (search truncated — likely many more)
- 7+ repositories with `.mise.toml` (hidden dotfile variant)
- Used across diverse teams: AgentPlugins, AryaFoundationalModel, HyperPodAICapabilities, MIPP Processing, CloudCast, FrugalCli, DnABusinessMetrics, and more

**Platforms where mise is used:**
- macOS developer laptops
- Cloud Desktops (AL2)
- Cloud Dev Machines (CDM)
- EC2 dev-dsk instances (confirmed in multiple wiki pages showing `dev-dsk-*` hostnames)
- WSL2 environments

**Typical tools managed via mise at Amazon:**
- Node.js (via `RtxNode` internal plugin or built-in core plugin)
- Python (3.9, 3.10, 3.11, 3.12)
- tmux (on AL2 where yum ships ancient 1.8)
- Poetry
- Bun

---

## 2. Official Recommendations

### BuilderHub / ASBX (Official Documentation)

From **[Using Python with the Peru dependency model](https://docs.hub.amazon.dev/languages/python/peru)**:

> To install and manage versions of Python, ASBX recommends that you use mise, a tool version manager that supports multiple tools and ecosystems via plugins.
>
> **Uninstall asdf** if you have it installed. It is likely to conflict with mise.
>
> mise is compatible with asdf's `.tool-versions` files and plugins, so it can be used as a drop-in replacement.

### AxE Builder Tools Installer (Official)

From **[Builder Tools installer](https://docs.hub.amazon.dev/axe/user-guide/init-builder-tools)**:

| Tool category  | Tool                          |
|----------------|-------------------------------|
| Idiomatic Tool | mise (formerly known as rtx)  |

Mise is listed as a standard tool installed by `axe init builder-tools` on **both macOS and AL2**.

### Individual Team Recommendations

From the **CommonSpeechMiddleware** Developer Tools wiki:

> Mise is a polyglot version manager written by an engineer who now works for Amazon Builder Tools. It replaces other tools (like pyenv, nvm, direnv) and provides a single, consistent interface to manage tooling versions across projects.
>
> **Mise is integrated into Peru build hosts already and will be the official buildertools-recommended solution for tooling version management.** I (gboylan@) recommend it over pyenv or similar managers.

From the **AWS Training & Certification** coding standards wiki:

> mise is written by an amazon engineer, and is now part of the core amazon builderhub tools setup, and we should use it to make interoperability between NAWS and BH seamless.

From the **Harmony Python Lambda Build Guide**:

> Node.js 22+ — Harmony CLI + MCPs require it. **mise is the easiest manager**. Homebrew works too.

### Peru / BuilderHub Blog

The Peru documentation references a blog post: **"peru-asdf-to-rtx"** (`https://builderhub.corp.amazon.com/blog/peru-asdf-to-rtx/`) which explicitly recommends switching from asdf to rtx/mise.

---

## 3. Amazon-Specific Integration

### RtxNode — Internal Node.js Plugin

The **[RtxNode](https://code.amazon.com/packages/RtxNode/trees/mainline)** package is an Amazon-internal asdf/mise plugin that:
- Downloads precompiled Node.js binaries built from Brazil's NodeJS packages
- Stored in S3 and fronted by CloudFront
- Supports both `mise` and `asdf` commands

```bash
# Install the Amazon Node.js plugin
mise plugin install nodejs ssh://git.amazon.com/pkg/RtxNode

# Install and set a default
mise install nodejs@lts
mise global nodejs@lts
```

**Note:** The RtxNode plugin does NOT support macOS — on macOS you should use mise's built-in core plugin instead:
```bash
mise plugin uninstall nodejs
mise use -g nodejs@lts
```

### AxE Integration

`axe init builder-tools` installs mise as part of the standard builder toolkit. After running AxE, Node.js binaries are located at:
```
~/.local/share/mise/installs/node/18.20.2/bin/node
```

### Shell Configuration

Recommended `.zshrc` configuration for Cloud Desktops:
```bash
# Initializing Mise for zsh
eval "$(/usr/bin/mise activate zsh --shims)"
eval "$(/usr/bin/mise activate zsh)"
```

---

## 4. Alternatives Comparison

| Tool | Status at Amazon | Notes |
|------|-----------------|-------|
| **mise** | ✅ **Official recommendation** | Installed by `axe init builder-tools`. Replaces all below. |
| **asdf** | ⚠️ **Deprecated in favor of mise** | BuilderHub explicitly says to uninstall asdf. |
| **pyenv** | ⚠️ Legacy | mise uses pyenv under the hood for Python compilation. Direct use is discouraged. |
| **nvm** | ⚠️ Legacy | Replaced by mise for Node.js version management. |
| **Builder Toolbox** | ✅ Complementary | Installs Amazon-specific CLI tools (brazil, ada, crux). Mise handles language runtimes. |
| **brazil-runtime-exec** | ✅ Build system (different scope) | For Brazil/Peru build environments. Mise is for local dev tooling. |
| **rustup** | ✅ Rust-specific | Still used for Rust (mise doesn't replace rustup for Rust). |

### Builder Toolbox vs Mise — No Conflict

Builder Toolbox and mise serve **different purposes** and are designed to work together:
- **Builder Toolbox**: Installs Amazon-proprietary CLI tools (brazil, ada, crux, git-lfs, etc.)
- **mise**: Manages language runtimes and ecosystem tools (node, python, poetry, etc.)

In fact, `axe init builder-tools` uses **both** — it installs some tools via Builder Toolbox and installs mise separately as an "Idiomatic Tool."

---

## 5. Known Issues / Caveats

1. **asdf conflict**: Do NOT install asdf alongside mise — they conflict. Mise can read `.tool-versions` files natively.

2. **macOS Node.js**: The internal `RtxNode` plugin only works on Linux. On macOS, use mise's built-in Node.js plugin.

3. **Shims for IDE support**: If using Bemol or VSCode Remote SSH, you need both shims and activation:
   ```bash
   eval "$(/usr/bin/mise activate zsh --shims)"
   eval "$(/usr/bin/mise activate zsh)"
   ```

4. **Git SSH access**: Installing `RtxNode` requires SSH access to `git.amazon.com`. Run `ssh git.amazon.com` once to accept the host key before using the plugin.

5. **Mise task runner**: Some teams (AgentPlugins, AryaFoundationalModel) use mise's task runner feature extensively (`mise run lint`, `mise run dev`, etc.) — this goes beyond simple version management.

---

## 6. Recommended Setup for Amazon Dev Environments

### Quick Start (macOS or Cloud Desktop)
```bash
# 1. Install Builder Toolbox (if not already)
# (follow https://docs.hub.amazon.dev/builder-toolbox/user-guide/getting-started)

# 2. Install AxE
toolbox install axe

# 3. Install standard builder tools (includes mise)
axe init builder-tools

# 4. (Optional) Install Amazon's Node.js plugin on Linux
mise plugin install nodejs ssh://git.amazon.com/pkg/RtxNode
mise install nodejs@lts
```

### For dotfiles / personal mise.toml
```toml
# ~/.config/mise/config.toml or project-level mise.toml
[tools]
python = "3.11"
node = "lts"

[env]
# Project-specific environment variables
```

---

## Sources

- [Using Python with the Peru dependency model](https://docs.hub.amazon.dev/languages/python/peru) — accessed 2026-06-17
- [Builder Tools installer (AxE)](https://docs.hub.amazon.dev/axe/user-guide/init-builder-tools) — accessed 2026-06-17
- [AxE Initialize documentation](https://docs.hub.amazon.dev/axe/user-guide/initialize) — accessed 2026-06-17
- [Windows (WSL2) Brazil CLI setup](https://docs.hub.amazon.dev/brazil/cli-guide/setup-wsl2) — accessed 2026-06-17
- [CommonSpeechMiddleware Developer Tools wiki](https://w.amazon.com/bin/view/CommonSpeechMiddleware/Core/DeveloperResources/DeveloperTools) — accessed 2026-06-17
- [AWS Training & Certification - Local Python Env](https://w.amazon.com/bin/view/AWS_Training_and_Certification/Curriculum/Engineering/Architecture/Builders/GeneralCodingStandards/LocalPythonEnv) — accessed 2026-06-17
- [GovCloud OpenSSH Setup - Mise section](https://w.amazon.com/bin/view/Main/ITAR_Govcloud/SettingupOpenSshonWindows) — accessed 2026-06-17
- [EC2 Chronos GMAdminTool Development Guide](https://w.amazon.com/bin/view/EC2/Chronos/Projects/GMAdminTool/GMAdminToolDevelopmentGuide) — accessed 2026-06-17
- [AWS ControlCompass Developer Setup](https://w.amazon.com/bin/view/AWS/ControlCompass/Documentation/Development/Developer-Setup) — accessed 2026-06-17
- [RtxNode package](https://code.amazon.com/packages/RtxNode/trees/mainline) — accessed 2026-06-17
- [Builder Toolbox documentation](https://docs.hub.amazon.dev/builder-toolbox) — accessed 2026-06-17
- [Harmony Python Lambda Build Guide](https://w.amazon.com/bin/view/AFAB/React/Harmony_Python_Lambda_Build_Guide) — accessed 2026-06-17
