# Validation

CI and `make validate` cover:

- YAML linting with `yamllint`.
- Flask unit tests with `pytest`.
- Docker image build.
- Kustomize rendering.
- Kubernetes schema validation with `kubeconform`.

`scripts/validate.sh` also runs `kubectl apply --dry-run=client` when a
Kubernetes cluster is reachable. GitHub Actions intentionally keeps validation
offline and relies on Kustomize plus kubeconform because kubectl resource
discovery requires an API server.

For live cluster validation:

```bash
make bootstrap
make build
make deploy
make smoke
```
