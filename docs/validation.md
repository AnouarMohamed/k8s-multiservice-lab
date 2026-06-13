# Validation

CI and `make validate` cover:

- YAML linting with `yamllint`.
- Flask unit tests with `pytest`.
- Docker image build.
- Kustomize rendering.
- Kubernetes schema validation with `kubeconform`.
- `kubectl apply --dry-run=client`.

For live cluster validation:

```bash
make bootstrap
make build
make deploy
make smoke
```

