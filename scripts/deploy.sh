#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${OVERLAY:-k8s/overlays/staging}"
NAMESPACE="${NAMESPACE:-stg}"

kubectl apply -k "${ROOT_DIR}/${OVERLAY}"
kubectl -n "$NAMESPACE" rollout status deployment/redis --timeout=120s
kubectl -n "$NAMESPACE" rollout status deployment/flask-api --timeout=120s
kubectl -n "$NAMESPACE" get deployment,replicaset,pod,svc,hpa,pdb
