#!/usr/bin/env bash
set -euo pipefail

PROMPT="${1:?Usage: cursor-bridge.sh \"prompt\" [workdir]}"
WORKDIR="${2:-/home/workspace}"
TIMEOUT="${CURSOR_TIMEOUT:-600}"
MODEL="${CURSOR_MODEL:-${SWARM_RESOLVED_MODEL:-auto}}"
FORCE="${CURSOR_FORCE:-1}"

if [[ -n "${CURSOR_AGENT_BIN:-}" ]]; then
  BIN="$CURSOR_AGENT_BIN"
elif command -v cursor-agent >/dev/null 2>&1; then
  BIN="$(command -v cursor-agent)"
elif [[ -x "${HOME:-/root}/.local/bin/cursor-agent" ]]; then
  BIN="${HOME:-/root}/.local/bin/cursor-agent"
else
  echo "ERROR: cursor-agent not found" >&2
  exit 1
fi

if [[ ! -d "$WORKDIR" ]]; then
  echo "ERROR: workdir does not exist: $WORKDIR" >&2
  exit 1
fi

case "$MODEL" in
  auto|byok:*|swarm-*|trivial|simple|moderate|complex|light|mid|heavy|failover)
    MODEL=""
    ;;
esac

ARGS=(-p --output-format json)
if [[ "$FORCE" == "1" ]]; then
  ARGS+=(--force)
fi
if [[ -n "$MODEL" ]]; then
  ARGS+=(--model "$MODEL")
fi
ARGS+=("$PROMPT")

OUTPUT_FILE="$(mktemp)"
ERROR_FILE="$(mktemp)"
trap 'rm -f "$OUTPUT_FILE" "$ERROR_FILE"' EXIT

if (cd "$WORKDIR" && timeout --signal=TERM --kill-after=10s "$TIMEOUT" "$BIN" "${ARGS[@]}") \
  >"$OUTPUT_FILE" 2>"$ERROR_FILE"; then
  :
else
  status=$?
  cat "$ERROR_FILE" >&2
  cat "$OUTPUT_FILE" >&2
  exit "$status"
fi

if ! jq -er 'select(.type == "result" and .subtype == "success" and .is_error == false) | .result' \
  <"$OUTPUT_FILE"; then
  echo "ERROR: cursor-agent returned an invalid result envelope" >&2
  cat "$ERROR_FILE" >&2
  cat "$OUTPUT_FILE" >&2
  exit 1
fi
