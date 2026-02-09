#!/bin/bash

echo "🛑 Stopping AIRS-CP local services..."

# Find and kill gateway process
GATEWAY_PID=$(pgrep -f "uvicorn airs_cp.gateway.app:app")
if [ -n "$GATEWAY_PID" ]; then
    kill $GATEWAY_PID 2>/dev/null
    echo "✅ Stopped gateway (PID: $GATEWAY_PID)"
else
    echo "   Gateway not running"
fi

# Find and kill dashboard process
DASHBOARD_PID=$(pgrep -f "uvicorn airs_cp.dashboard.app:app")
if [ -n "$DASHBOARD_PID" ]; then
    kill $DASHBOARD_PID 2>/dev/null
    echo "✅ Stopped dashboard (PID: $DASHBOARD_PID)"
else
    echo "   Dashboard not running"
fi

echo ""
echo "✨ All services stopped"
