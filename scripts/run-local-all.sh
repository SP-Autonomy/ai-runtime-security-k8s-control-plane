#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting AIRS-CP (Gateway + Dashboard)"
echo ""

# Check if tmux is available
if command -v tmux &> /dev/null; then
    echo "Using tmux to run services in split panes"
    echo "Press Ctrl+B then D to detach, or Ctrl+C to stop all"
    echo ""
    sleep 2

    # Create new tmux session with gateway
    tmux new-session -d -s airs-cp -n main "$SCRIPT_DIR/run-local-gateway.sh"

    # Split window and run dashboard
    tmux split-window -h -t airs-cp:main "$SCRIPT_DIR/run-local-dashboard.sh"

    # Attach to session
    tmux attach-session -t airs-cp
else
    echo "Tmux not found. Running in background..."
    echo ""

    # Run gateway in background
    "$SCRIPT_DIR/run-local-gateway.sh" > /tmp/airs-gateway.log 2>&1 &
    GATEWAY_PID=$!
    echo "Gateway started (PID: $GATEWAY_PID)"
    echo "  Logs: tail -f /tmp/airs-gateway.log"

    # Wait a bit for gateway to start
    sleep 3

    # Run dashboard in background
    "$SCRIPT_DIR/run-local-dashboard.sh" > /tmp/airs-dashboard.log 2>&1 &
    DASHBOARD_PID=$!
    echo "Dashboard started (PID: $DASHBOARD_PID)"
    echo "  Logs: tail -f /tmp/airs-dashboard.log"

    echo ""
    echo "✨ Services running in background"
    echo ""
    echo "Gateway:   http://localhost:8080"
    echo "Dashboard: http://localhost:8501/dashboard"
    echo ""
    echo "To stop: ./scripts/stop-local.sh"
    echo ""
fi
