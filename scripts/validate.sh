#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${OVERLAY:-k8s/overlays/staging}"
NAMESPACE="${NAMESPACE:-stg}"
RENDERED="$(mktemp)"
trap 'rm -f "$RENDERED"' EXIT

if command -v yamllint >/dev/null 2>&1; then
  echo "Running yamllint"
  yamllint "$ROOT_DIR"
else
  echo "Skipping yamllint: command not found" >&2
fi

if command -v pytest >/dev/null 2>&1; then
  echo "Running pytest"
  PYTHONPATH="${ROOT_DIR}/app" pytest "${ROOT_DIR}/app/tests"
else
  echo "Skipping pytest: command not found" >&2
fi

echo "Rendering ${OVERLAY}"
kubectl kustomize "${ROOT_DIR}/${OVERLAY}" >"$RENDERED"

if command -v kubeconform >/dev/null 2>&1; then
  echo "Running kubeconform"
  kubeconform -strict -summary -ignore-missing-schemas "$RENDERED"
else
  echo "Skipping kubeconform: command not found" >&2
fi

if kubectl cluster-info >/dev/null 2>&1; then
  echo "Running client-side dry-run"
  kubectl apply -f "$RENDERED" --dry-run=client

  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Running server-side dry-run"
    kubectl apply -f "$RENDERED" --dry-run=server
  else
    echo "Skipping server-side dry-run: namespace ${NAMESPACE} does not exist yet" >&2
  fi
else
  echo "Skipping kubectl dry-run: no reachable cluster" >&2
fi

echo "Validation complete"
