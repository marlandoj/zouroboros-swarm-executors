---
name: zo-swarm-executors
description: Local executor system for zo-swarm-orchestrator — manages bridge scripts, health checks, and registry for Claude Code and Hermes agents
version: 1.0.0
author: marlandoj
tags:
  - swarm
  - orchestration
  - local-executors
  - bridge-scripts
related_skills:
  - zo-swarm-orchestrator
---

# zo-swarm-executors

Local executor system for the [zo-swarm-orchestrator](../zo-swarm-orchestrator/). Manages bridge scripts, executor registry, and health checks for AI agents that run directly on the machine (not via remote API).

## Quick Start

```bash
cd /home/workspace/Skills/zo-swarm-executors

# Check executor health
bun scripts/doctor.ts

# Integration test (sends test prompt through each bridge)
bun scripts/test-harness.ts

# List registered executors
bun scripts/register.ts list

# Validate registry schema
bun scripts/register.ts validate
```

## Available Executors

| ID | Name | Bridge | Best For |
|----|------|--------|----------|
| `claude-code` | Claude Code | `bridges/claude-code-bridge.sh` | Code implementation, file editing, git operations |
| `hermes` | Hermes Agent | `bridges/hermes-bridge.sh` | Web research, multi-tool investigation, messaging |

## Bridge Protocol

Bridges are shell scripts that wrap a local AI agent for orchestrator invocation:

```bash
bash <bridge> "<prompt>" [workdir]
# stdout = clean text response
# stderr = diagnostics
# exit 0 = success, non-zero = failure
```

See [docs/BRIDGE_PROTOCOL.md](docs/BRIDGE_PROTOCOL.md) for the full specification.

## Integration with zo-swarm-orchestrator

The orchestrator reads `registry/executor-registry.json` to discover local executors. Set the registry path via:

```bash
export SWARM_EXECUTOR_REGISTRY=/home/workspace/Skills/zo-swarm-executors/registry/executor-registry.json
```

Or let the orchestrator use its default path: `Skills/zo-swarm-executors/registry/executor-registry.json` relative to `SWARM_WORKSPACE`.

## Adding a Custom Executor

1. Copy `bridges/template-bridge.sh` and implement your executor
2. Create a JSON file with executor metadata (see `executor-registry.json` for schema)
3. Register: `bun scripts/register.ts add my-executor.json`
4. Verify: `bun scripts/doctor.ts --executor my-executor`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SWARM_WORKSPACE` | `/home/workspace` | Workspace root for path resolution |
| `SWARM_EXECUTOR_REGISTRY` | `Skills/zo-swarm-executors/registry/executor-registry.json` | Path to executor registry |
| `CLAUDE_CODE_BIN` | Auto-detected | Path to Claude Code CLI binary |
| `CLAUDE_CODE_MODEL` | CLI default | Override Claude Code model |
| `CLAUDE_CODE_TIMEOUT` | `600` | Claude Code bridge timeout (seconds) |
| `HERMES_PROJECT_DIR` | `/home/workspace/hermes-agent` | Path to Hermes project directory |
| `HERMES_VENV` | `$HERMES_PROJECT_DIR/.venv/bin/activate` | Path to Hermes venv activate script |
