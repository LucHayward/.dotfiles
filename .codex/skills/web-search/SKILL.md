---
name: web-search
description: Web search alternative when native web search is unavailable or rate-limited. Use when you need to search the web, find URLs, search the internet, or look something up online. This proxies search through `kiro-cli` using the `web-search` agent and returns JSON-formatted results.
---

# Web Search (via Kiro CLI)

## Instructions

When you need to search the web and native web search is not available, run:

```bash
kiro-cli chat --no-interactive --agent web-search "<query>"
```

This returns a JSON array of `{title, url, snippet}` objects.

If `kiro-cli` is not authenticated and the command fails with an auth error, ask the user to authenticate with:

```bash
kiro-cli login --use-device-flow
```

After getting results, open the most relevant URLs with the appropriate fetch or browser-reading tools available in the current environment.
