#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="ai-security"
RELEASE="airs-cp"

helm uninstall "${RELEASE}" -n "${NAMESPACE}" || true
echo "AIRS-CP removed."
