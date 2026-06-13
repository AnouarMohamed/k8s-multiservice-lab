# Runbook

## Bootstrap k3s

```bash
make bootstrap
```

The script starts k3s with Traefik disabled and the native snapshotter enabled,
which works well in Codespaces-style containerized environments.

## Build the API Image

```bash
make build
```

The image is tagged as `flask-api:stg` and imported into k3s containerd so the
Deployment can use `imagePullPolicy: Never`. If the current Kubernetes context
is a kind cluster, the script loads the same image into kind instead.

## Deploy

```bash
make deploy
```

Verify:

```bash
make status
kubectl -n stg get pods -o wide
kubectl -n stg describe deployment flask-api
```

## Access

```bash
make port-forward
```

Then call:

```bash
curl http://127.0.0.1:5000/
curl http://127.0.0.1:5000/healthz
curl http://127.0.0.1:5000/readyz
curl http://127.0.0.1:5000/metrics
```

## Rolling Restart

```bash
make restart
```

## Self-Healing Test

```bash
POD="$(kubectl -n stg get pod -l app.kubernetes.io/name=flask-api -o jsonpath='{.items[0].metadata.name}')"
kubectl -n stg delete pod "$POD"
kubectl -n stg rollout status deployment/flask-api --timeout=120s
kubectl -n stg get pods
```

## Cleanup

```bash
make clean
```
