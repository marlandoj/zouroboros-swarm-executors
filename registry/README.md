# Executor registry

The canonical runtime registry is `packages/swarm/src/executor/registry/executor-registry.json`.

The swarm loader, doctor, registration utility, and harness tester all use that file by default.
Set `SWARM_EXECUTOR_REGISTRY` only for an intentional test or workspace-local override.
