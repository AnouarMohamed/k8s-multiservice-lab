#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stg}"
LOCAL_PORT="${1:-${LOCAL_PORT:-5000}}"

kubectl -n "$NAMESPACE" port-forward svc/flask-api-svc "${LOCAL_PORT}:80"
