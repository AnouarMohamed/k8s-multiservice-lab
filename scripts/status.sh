#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stg}"

kubectl get nodes -o wide
kubectl -n "$NAMESPACE" get deployment,replicaset,pod,svc,hpa,pdb,networkpolicy,resourcequota,limitrange,configmap,secret
kubectl -n "$NAMESPACE" rollout status deployment/redis --timeout=30s
kubectl -n "$NAMESPACE" rollout status deployment/flask-api --timeout=30s
