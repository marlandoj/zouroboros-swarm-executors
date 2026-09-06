#!/usr/bin/env bash
set -euo pipefail

if ! command -v kimi >/dev/null 2>&1; then
  echo "ERROR: kimi not found" >&2
  exit 1
fi

if [[ -z "${KIMI_MODEL_API_KEY:-}" ]]; then
  if [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
    export KIMI_MODEL_API_KEY="$OPENROUTER_API_KEY"
    export KIMI_MODEL_BASE_URL="${KIMI_MODEL_BASE_URL:-https://openrouter.ai/api/v1}"
    export KIMI_MODEL_NAME="${KIMI_MODEL_NAME:-moonshotai/kimi-k3}"
  elif [[ -n "${KIMI_API_KEY:-}" ]]; then
    export KIMI_MODEL_API_KEY="$KIMI_API_KEY"
  fi
fi
export KIMI_MODEL_NAME="${KIMI_MODEL_NAME:-moonshotai/kimi-k3}"
export KIMI_DISABLE_TELEMETRY="${KIMI_DISABLE_TELEMETRY:-1}"

# Load shared secrets (OPENAI_API_KEY, QDRANT_URL, QDRANT_API_KEY, ...) so MCP
# servers spawned by kimi inherit them. File is 0640 root:zouroboros; never printed.
if [ -r /etc/zouroboros/zouroboros.env ]; then
  set -a
  . /etc/zouroboros/zouroboros.env
  set +a
fi

if [[ "${1:-}" == "--acp" ]]; then
  exec kimi acp
fi

PROMPT="${1:?Usage: kimi-bridge.sh \"prompt\" [workdir]}"
WORKDIR="${2:-/home/workspace}"
TIMEOUT="${KIMI_TIMEOUT:-600}"

cd "$WORKDIR"
timeout --signal=TERM --kill-after=10s "$TIMEOUT" \
  kimi --prompt "$PROMPT"
