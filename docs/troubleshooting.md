# Troubleshooting

## API pods are stuck in ImagePullBackOff

The Deployment uses `imagePullPolicy: Never` because this lab imports a local
image into k3s.

```bash
make build
kubectl -n stg rollout restart deployment/flask-api
```

## API pods are not Ready

Readiness checks Redis. Inspect both services:

```bash
kubectl -n stg describe deployment flask-api
kubectl -n stg logs -l app.kubernetes.io/name=flask-api --tail=100
kubectl -n stg get endpoints redis-svc
```

## Redis is not Ready

```bash
kubectl -n stg describe deployment redis
kubectl -n stg logs deployment/redis
kubectl -n stg get events --sort-by=.lastTimestamp
```

## Port-forward fails

```bash
kubectl -n stg get svc flask-api-svc
kubectl -n stg get endpoints flask-api-svc
kubectl -n stg port-forward svc/flask-api-svc 5000:80
```

## HPA has unknown metrics

k3s normally includes metrics-server, but it may take time to report metrics.

```bash
kubectl top pods -n stg
kubectl -n stg describe hpa flask-api
```

## Pods stay Pending because all nodes are tainted

Some local kind clusters are intentionally tainted and will not schedule normal
workloads.

```bash
kubectl describe nodes | grep -A3 Taints
```

Use a schedulable k3s/kind cluster, or remove the local lab taints if that is
appropriate for your environment.
