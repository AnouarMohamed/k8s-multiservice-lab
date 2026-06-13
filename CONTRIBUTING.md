# Contributing

Keep this repository reproducible from a clean clone.

## Local Checks

```bash
make validate
make build
```

With a running k3s cluster:

```bash
make deploy
make smoke
```

## Guidelines

- Keep reusable Kubernetes objects in `k8s/base`.
- Keep environment-specific values in `k8s/overlays/<env>`.
- Do not commit real secrets. Use Kustomize generators or external secret tooling.
- Keep all containers with resource requests, limits, probes, and security context.
- Update the runbook when operator commands change.
