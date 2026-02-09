#!/bin/bash

echo "🌉 Bridging Kubernetes Ollama to Local"
echo "======================================="
echo ""

# Check if port 11435 is already in use
if lsof -Pi :11435 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 11435 already in use"
    PID=$(lsof -Pi :11435 -sTCP:LISTEN -t)
    echo "   Killing existing process (PID: $PID)"
    kill $PID 2>/dev/null
    sleep 2
fi

echo "🔗 Setting up port-forward to Kubernetes Ollama..."
echo "   Kubernetes: ai-app/ollama:11434"
echo "   Local:      localhost:11435"
echo ""

# Run port-forward in background
nohup kubectl port-forward -n ai-app svc/ollama 11435:11434 > /tmp/k8s-ollama-forward.log 2>&1 &
PF_PID=$!

echo "✅ Port-forward started (PID: $PF_PID)"
echo "   Logs: /tmp/k8s-ollama-forward.log"
echo ""

# Wait a moment and verify
sleep 3

if curl -s http://localhost:11435/api/tags > /dev/null 2>&1; then
    echo "✅ Kubernetes Ollama accessible at http://localhost:11435"
    K8S_MODELS=$(curl -s http://localhost:11435/api/tags | jq -r '.models[] | .name' | wc -l)
    echo "   Found $K8S_MODELS model(s) in Kubernetes Ollama"
else
    echo "❌ Cannot connect to Kubernetes Ollama"
    echo "   Check: kubectl get pods -n ai-app -l app=ollama"
fi

echo ""
echo "📝 To stop: pkill -f 'port-forward.*11435'"
echo ""
