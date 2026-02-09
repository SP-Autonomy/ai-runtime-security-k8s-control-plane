#!/bin/bash
set -e

echo "🚀 Starting AIRS-CP Distributed Environment"
echo "==========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# 1. Start local gateway
echo "1️⃣ Starting local gateway (port 8080)..."
./scripts/run-local-gateway.sh > /tmp/local-gateway.log 2>&1 &
sleep 4

# 2. Setup K8s port-forward
echo "2️⃣ Setting up Kubernetes gateway port-forward (9080→8080)..."
pkill -f "port-forward.*ai-security.*9080" 2>/dev/null || true
sleep 1
kubectl port-forward -n ai-security svc/airs-cp-gateway 9080:8080 > /tmp/k8s-pf.log 2>&1 &
sleep 4

# 3. Start unified dashboard
echo "3️⃣ Starting unified dashboard (port 8501)..."
./scripts/run-local-dashboard.sh > /tmp/dashboard.log 2>&1 &
sleep 4

# Verify all services
echo ""
echo "✅ Verifying services..."
echo ""

if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Local gateway:  http://localhost:8080"
else
    echo "❌ Local gateway not responding"
fi

if curl -s http://localhost:9080/health > /dev/null 2>&1; then
    echo "✅ K8s gateway:    http://localhost:9080 (port-forward)"
else
    echo "❌ K8s gateway not responding"
fi

if curl -s http://localhost:8501/dashboard > /dev/null 2>&1; then
    echo "✅ Dashboard:      http://localhost:8501/dashboard"
else
    echo "❌ Dashboard not responding"
fi

echo ""
echo "🎯 Unified Dashboard: http://localhost:8501/dashboard"
echo "   • Aggregates from 2 gateways"
echo "   • Shows local + Kubernetes models"
echo "   • Combines alerts from both sources"
echo ""
echo "📝 Logs:"
echo "   Local gateway:  tail -f /tmp/local-gateway.log"
echo "   K8s port-fwd:   tail -f /tmp/k8s-pf.log"
echo "   Dashboard:      tail -f /tmp/dashboard.log"
echo ""
echo "🛑 To stop: ./scripts/stop-distributed.sh"
echo ""
