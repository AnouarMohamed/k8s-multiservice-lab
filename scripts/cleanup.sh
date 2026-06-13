#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stg}"

kubectl delete namespace "$NAMESPACE" --ignore-not-found
