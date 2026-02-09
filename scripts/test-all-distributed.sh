#!/bin/bash

echo "🚨 AIRS-CP Distributed Security Testing"
echo "========================================"
echo ""
echo "This will test security detection across:"
echo "  • Local Gateway (localhost:8080)"
echo "  • Kubernetes Gateway (localhost:9080 + in-cluster)"
echo ""
echo "All detections will appear in the unified dashboard!"
echo ""
read -p "Press Enter to start..."
echo ""

# Test Local Gateway
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PART 1: Local Gateway Attacks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./scripts/test-local-attacks.sh

echo ""
echo "Waiting 3 seconds before K8s tests..."
sleep 3

# Test Kubernetes Gateway (via port-forward)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PART 2: Kubernetes Gateway Attacks (via port-forward)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./scripts/test-k8s-attacks.sh

echo ""
echo "Waiting 3 seconds before cluster-internal tests..."
sleep 3

# Test from inside cluster
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PART 3: Attacks from Inside Cluster (debug pod)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./scripts/test-k8s-from-pod.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL TESTS COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 View results in unified dashboard:"
echo "   http://localhost:8501/dashboard"
echo ""
echo "You should see detections from:"
echo "   • 5 local attacks (PII, injection, commands)"
echo "   • 5 K8s attacks via port-forward"
echo "   • 4 cluster-internal attacks"
echo ""
echo "Total: ~14 attack attempts across 2 gateways!"
echo ""
