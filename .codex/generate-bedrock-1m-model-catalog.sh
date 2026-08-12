#!/usr/bin/env bash

set -euo pipefail

# Temporary workaround until the internal Codex wrapper publishes 1M metadata.
catalog_path="${1:-$HOME/.codex/model_catalog.json}"
codex_bin="${CODEX_BIN:-}"

if [[ -z "$codex_bin" ]]; then
    if command -v codex >/dev/null 2>&1; then
        codex_bin="$(command -v codex)"
    else
        codex_bin="$HOME/.toolbox/bin/codex"
    fi
fi

if [[ ! -x "$codex_bin" ]]; then
    echo "Codex executable not found: $codex_bin" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to generate the model catalog" >&2
    exit 1
fi

catalog_dir="$(dirname "$catalog_path")"
mkdir -p "$catalog_dir"
tmp_path="$(mktemp "$catalog_dir/.model_catalog.XXXXXX")"
trap 'rm -f "$tmp_path"' EXIT

"$codex_bin" debug models --bundled | jq '
  .models as $all
  | def bedrock_variant($source; $slug; $name; $description):
      ($all[] | select(.slug == $source))
      | .slug = $slug
      | .display_name = $name
      | .description = $description
      | .visibility = "list"
      | .context_window = 1048576
      | .max_context_window = 1048576
      | .multi_agent_version = "v1";
  .models = (
    [.models[]
      | select(.slug != "openai.gpt-5.6-sol")
      | select(.slug != "openai.gpt-5.6-terra")
      | select(.slug != "openai.gpt-5.6-luna")
      | if (.slug == "gpt-5.6-sol" or .slug == "gpt-5.6-terra" or .slug == "gpt-5.6-luna")
        then .visibility = "hide"
        else .
        end]
    + [
        bedrock_variant("gpt-5.6-sol"; "openai.gpt-5.6-sol"; "[1M] GPT-5.6-Sol"; "[1M context] Latest frontier agentic coding model."),
        bedrock_variant("gpt-5.6-terra"; "openai.gpt-5.6-terra"; "[1M] GPT-5.6-Terra"; "[1M context] Balanced agentic coding model for everyday work."),
        bedrock_variant("gpt-5.6-luna"; "openai.gpt-5.6-luna"; "[1M] GPT-5.6-Luna"; "[1M context] Fast and affordable agentic coding model.")
      ]
  )
' > "$tmp_path"

jq -e '
  ([.models[] | select(.slug | test("^openai\\.gpt-5\\.6-(sol|terra|luna)$"))] | length == 3)
  and (all(
    .models[]
    | select(.slug | test("^openai\\.gpt-5\\.6-(sol|terra|luna)$"));
    .context_window == 1048576
    and .max_context_window == 1048576
    and .multi_agent_version == "v1"
    and .visibility == "list"
  ))
  and (all(
    .models[]
    | select(.slug | test("^gpt-5\\.6-(sol|terra|luna)$"));
    .visibility == "hide"
  ))
' "$tmp_path" >/dev/null

chmod 600 "$tmp_path"
mv "$tmp_path" "$catalog_path"
trap - EXIT

echo "Generated $catalog_path with 1M Sol, Terra, and Luna entries."
