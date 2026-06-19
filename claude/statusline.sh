#!/bin/bash
# Claude Code status line - shows model, context, rate limits, cost
input=$(cat)

# Colors
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BLUE=$'\033[34m'
DIM=$'\033[2m'
RST=$'\033[0m'
SEP=" ${DIM}│${RST} "

# Parse JSON
{
  read -r MODEL
  read -r PCT_RAW
  read -r FIVE_PCT
  read -r SEVEN_PCT
  read -r COST
} < <(echo "$input" | jq -r '
  (.model.display_name // "—"),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.cost.total_cost_usd // 0)
')

# Context bar
PCT=0
if [[ -n "$PCT_RAW" && "$PCT_RAW" != "null" ]]; then
  PCT=${PCT_RAW%%.*}
  (( PCT < 0 )) && PCT=0; (( PCT > 100 )) && PCT=100
fi
if   (( PCT >= 60 )); then BC="$RED"
elif (( PCT >= 40 )); then BC="$YELLOW"
else BC="$GREEN"; fi

F=$((PCT / 10)); E=$((10 - F)); BAR=""
for ((i=0; i<F; i++)); do BAR+="█"; done
for ((i=0; i<E; i++)); do BAR+="░"; done

# Rate limits
RLIM=""
if [[ -n "$FIVE_PCT" && "$FIVE_PCT" != "null" ]]; then
  FI=$(printf '%.0f' "$FIVE_PCT")
  if   (( FI >= 80 )); then RC="$RED"
  elif (( FI >= 50 )); then RC="$YELLOW"
  else RC="$DIM"; fi
  RLIM="${SEP}${RC}5h: ${FI}%${RST}"
fi
if [[ -n "$SEVEN_PCT" && "$SEVEN_PCT" != "null" ]]; then
  SI=$(printf '%.0f' "$SEVEN_PCT")
  if   (( SI >= 80 )); then SC="$RED"
  elif (( SI >= 50 )); then SC="$YELLOW"
  else SC="$DIM"; fi
  RLIM+="${SEP}${SC}7d: ${SI}%${RST}"
fi

# Cost
COST_SEG=""
if [[ -n "$COST" && "$COST" != "null" && "$COST" != "0" ]]; then
  COST_SEG="${SEP}${DIM}\$$(printf '%.2f' "$COST")${RST}"
fi

printf '%s\n' "${BLUE}${MODEL}${RST}${SEP}${BC}${BAR}${RST} ${PCT}%${RLIM}${COST_SEG}"
