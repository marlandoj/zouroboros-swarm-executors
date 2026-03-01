# AGENTS.md — zo-swarm-executors

Agent memory for AI coding assistants working on this project.

## Design Decisions

1. **Registry-based integration** — The orchestrator reads `executor-registry.json` via a configurable path (`SWARM_EXECUTOR_REGISTRY`). No TypeScript import coupling between skills.

2. **Bridge scripts as interface** — Shell scripts are the universal interface. Any agent that can be invoked via CLI can become a local executor by implementing the bridge protocol.

3. **Identity files are references** — Canonical identity files live in `/home/workspace/IDENTITY/`. The `docs/identities/` copies are for documentation only.

4. **Backwards compatibility** — The orchestrator falls back to `persona-registry.json` (filtering `executor === "local"`) if the executor registry is not found.

## File Layout

```
bridges/          — Executable bridge scripts (the core interface)
registry/         — Executor registry JSON (consumed by orchestrator)
scripts/          — Management tools (doctor, test-harness, register)
types/            — TypeScript interfaces for the registry schema
docs/             — Protocol spec and reference identity files
```

## Key Patterns

- All paths in the registry are relative to `SWARM_WORKSPACE` (default: `/home/workspace`)
- Bridge scripts use `set -euo pipefail` and validate `$1` is provided
- Doctor checks: bridge exists, executable, health command, env vars
- Test harness sends `"Respond with exactly: BRIDGE_OK"` and validates output

## Known Limitations

- Hermes bridge output parsing relies on specific banner format (`╭─ ⚕ Hermes` ... `╰──`). If Hermes CLI changes its output format, the sed pipeline will break.
- Claude Code bridge requires `settings.json` with `defaultMode: bypassPermissions` since `--dangerously-skip-permissions` is blocked when running as root.
- No Windows support — bridges are bash scripts.

## Integration Notes

- Orchestrator file: `Skills/zo-swarm-orchestrator/scripts/orchestrate-v4.ts`
- Orchestrator reads registry at: `PATHS.executorRegistry`
- Orchestrator calls bridges at: `callLocalAgent()` method
- Split concurrency: `localConcurrency` pool separate from `maxConcurrency` (API)
