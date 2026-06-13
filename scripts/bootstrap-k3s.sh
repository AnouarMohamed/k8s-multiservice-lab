#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${K3S_LOG_FILE:-/tmp/k3s-multiservice-lab.log}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if ! need_cmd k3s; then
  echo "Installing k3s binary"
  curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -
fi

if ! pgrep -f "k3s server" >/dev/null 2>&1; then
  echo "Starting k3s server. Logs: ${LOG_FILE}"
  sudo nohup k3s server --disable=traefik --snapshotter=native >"$LOG_FILE" 2>&1 &
fi

echo "Waiting for kubeconfig"
for _ in {1..90}; do
  if sudo test -f /etc/rancher/k3s/k3s.yaml; then
    break
  fi
  sleep 2
done

mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"

kubectl wait --for=condition=Ready node --all --timeout=180s
kubectl -n kube-system get pods
