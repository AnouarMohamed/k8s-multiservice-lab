#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-flask-api:stg}"

docker build -t "$IMAGE" ./app

if command -v k3s >/dev/null 2>&1 && pgrep -f "k3s server" >/dev/null 2>&1; then
  echo "Importing ${IMAGE} into k3s containerd"
  docker save "$IMAGE" | sudo k3s ctr images import -
elif command -v kind >/dev/null 2>&1 && kubectl config current-context 2>/dev/null | grep -q '^kind-'; then
  context="$(kubectl config current-context)"
  cluster="${KIND_CLUSTER_NAME:-${context#kind-}}"
  echo "Loading ${IMAGE} into kind cluster ${cluster}"
  kind load docker-image "$IMAGE" --name "$cluster"
else
  echo "Skipping cluster image import: no running k3s or active kind context detected" >&2
fi
