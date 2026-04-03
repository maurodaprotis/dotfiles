#!/usr/bin/env bash
# Claude Code compact status line — pie circle + model glyph

input=$(cat)

# Model symbol
model_id=$(echo "$input" | jq -r '.model.id // ""')
case "$model_id" in
  *opus*)   model_sym="◆" ;;
  *sonnet*) model_sym="◇" ;;
  *haiku*)  model_sym="·" ;;
  *)        model_sym="○" ;;
esac

# Context pie (○ ◔ ◑ ◕ ●)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  pct=$(printf "%.0f" "$used")
  if   [ "$pct" -le 5 ];  then pie="○"
  elif [ "$pct" -le 25 ]; then pie="◔"
  elif [ "$pct" -le 50 ]; then pie="◑"
  elif [ "$pct" -le 75 ]; then pie="◕"
  else                          pie="●"
  fi
  printf "%s %s %s%%" "$model_sym" "$pie" "$pct"
else
  printf "%s" "$model_sym"
fi
