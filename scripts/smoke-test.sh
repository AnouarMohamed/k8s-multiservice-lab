#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stg}"
LOCAL_PORT="${LOCAL_PORT:-15000}"
BASE_URL="http://127.0.0.1:${LOCAL_PORT}"
LOG_FILE="$(mktemp)"

cleanup() {
  if [ -n "${PF_PID:-}" ] && kill -0 "$PF_PID" >/dev/null 2>&1; then
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
  rm -f "$LOG_FILE"
}
trap cleanup EXIT

kubectl -n "$NAMESPACE" rollout status deployment/redis --timeout=120s
kubectl -n "$NAMESPACE" rollout status deployment/flask-api --timeout=120s
kubectl -n "$NAMESPACE" port-forward svc/flask-api-svc "${LOCAL_PORT}:80" >"$LOG_FILE" 2>&1 &
PF_PID="$!"

for _ in {1..30}; do
  if curl -fsS "${BASE_URL}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

curl -fsS "${BASE_URL}/healthz" | grep -q '"status":"healthy"'
curl -fsS "${BASE_URL}/readyz" | grep -q '"redis":"ok"'
curl -fsS "${BASE_URL}/" | grep -q '"hits"'
curl -fsS "${BASE_URL}/metrics" | grep -q "flask_api_hits_total"

echo "Smoke test passed: ${BASE_URL}"
