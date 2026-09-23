#!/usr/bin/env bash

MODEL_CATALOG_PATH="${SWARM_MODEL_CATALOG_PATH:-/home/workspace/.runtime/swarm-model-catalog/v1/current.json}"

catalog_tier() {
  case "$1" in
    trivial|simple|light|haiku|flash|mini|swarm-light) printf '%s' light ;;
    moderate|mid|sonnet|balanced|swarm-mid) printf '%s' mid ;;
    complex|heavy|opus|pro|frontier|swarm-heavy) printf '%s' heavy ;;
    *) printf '%s' mid ;;
  esac
}

catalog_model() {
  local executor="$1"
  local requested_tier="$2"
  local fallback="$3"
  local selected_tier
  selected_tier="$(catalog_tier "$requested_tier")"
  local path="$MODEL_CATALOG_PATH"
  if [ ! -f "$path" ]; then
    path="$(dirname "$MODEL_CATALOG_PATH")/last-known-good.json"
  fi
  if command -v jq >/dev/null 2>&1 && [ -f "$path" ]; then
    local model
    model="$(jq -r --arg executor "$executor" --arg tier "$selected_tier" '.routes[$executor].qualification[$tier] | select(.qualified == true) | .model // empty' "$path" 2>/dev/null || true)"
    if [ -n "$model" ] && [ "$model" != "null" ]; then
      printf '%s' "$model"
      return 0
    fi
  fi
  printf '%s' "$fallback"
}
