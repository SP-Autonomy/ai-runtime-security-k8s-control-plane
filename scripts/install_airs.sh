#!/usr/bin/env bash
set -euo pipefail

# Adjust these once you confirm where the Helm chart lives in your AIRS-CP repo.
# Example possibilities:
#   vendor/airs-cp/helm/airs-cp
#   vendor/airs-cp/charts/airs-cp
CHART_PATH="vendor/airs-cp/helm/airs-cp"

NAMESPACE="ai-security"
RELEASE="airs-cp"

# Values file you’ll create in THIS repo to keep deployment reproducible
VALUES_FILE="helm/airs-cp/values-kind.yaml"

if [ ! -d "${CHART_PATH}" ]; then
  echo "ERROR: Helm chart not found at ${CHART_PATH}"
  echo "Fix CHART_PATH in scripts/install_airs.sh after inspecting vendor/airs-cp"
  exit 1
fi

kubectl get ns "${NAMESPACE}" >/dev/null 2>&1 || kubectl create ns "${NAMESPACE}"

helm upgrade --install "${RELEASE}" "${CHART_PATH}" \
  -n "${NAMESPACE}" \
  -f "${VALUES_FILE}"

echo "AIRS-CP installed."
