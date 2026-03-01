#!/usr/bin/env bash
# Hermes bridge script — invokes Hermes CLI in single-query mode
# Strips banner/chrome, returns only the response text
#
# Usage:
#   ./hermes-bridge.sh "Your prompt here"
#
# Environment:
#   HERMES_PROJECT_DIR — path to hermes-agent project (default: /home/workspace/hermes-agent)
#   HERMES_VENV        — path to venv activate script (default: $HERMES_PROJECT_DIR/.venv/bin/activate)

set -euo pipefail

PROMPT="${1:?Usage: hermes-bridge.sh \"prompt\"}"
PROJECT_DIR="${HERMES_PROJECT_DIR:-/home/workspace/hermes-agent}"
VENV_ACTIVATE="${HERMES_VENV:-$PROJECT_DIR/.venv/bin/activate}"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Hermes project dir not found: $PROJECT_DIR" >&2
  exit 1
fi

if [ ! -f "$VENV_ACTIVATE" ]; then
  echo "ERROR: Hermes venv not found: $VENV_ACTIVATE" >&2
  exit 1
fi

cd "$PROJECT_DIR"
unset OPENAI_API_KEY
source "$VENV_ACTIVATE"

# Run Hermes in quiet single-query mode, strip banner chrome
python cli.py -q "$PROMPT" 2>/dev/null \
  | sed -n '/^╭─ ⚕ Hermes/,/^╰──/p' \
  | sed '1d;$d' \
  | sed 's/\r//g' \
  | sed '/^$/d'
