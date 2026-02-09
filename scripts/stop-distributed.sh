#!/bin/bash

echo "🛑 Stopping AIRS-CP Distributed Environment"
echo "==========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Stop local services
echo "Stopping local gateway and dashboard..."
./scripts/stop-local.sh

# Stop K8s port-forward
echo "Stopping K8s port-forward..."
pkill -f "port-forward.*ai-security.*9080" && echo "✅ K8s gateway port-forward stopped" || echo "   Not running"

echo ""
echo "✨ All distributed services stopped"
echo ""
