#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$REPO_ROOT/vendor/airs-cp"
ENV_FILE="$REPO_ROOT/.env.local"

# Check if setup was run
if [ ! -d "$VENDOR_DIR/venv" ]; then
    echo "❌ Virtual environment not found. Run ./scripts/setup-local.sh first"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env.local not found. Run ./scripts/setup-local.sh first"
    exit 1
fi

# Clear any existing AIRS/OLLAMA environment variables to avoid conflicts
for var in $(env | grep -E '^(AIRS_|OLLAMA_|OPENAI_|ANTHROPIC_|AZURE_)' | cut -d= -f1); do
    unset $var
done

# Load environment variables from .env.local
set -a  # automatically export all variables
source "$ENV_FILE"
set +a

# Activate virtual environment
source "$VENDOR_DIR/venv/bin/activate"

# Navigate to source directory
cd "$VENDOR_DIR/src"

# Get ports from env or use defaults
DASHBOARD_PORT=${AIRS_DASHBOARD_PORT:-8501}
GATEWAY_URL=${AIRS_GATEWAY_URL:-http://localhost:8080}

# Check if gateway is running
if ! curl -s "$GATEWAY_URL/health" > /dev/null 2>&1; then
    echo "⚠️  Gateway not responding at $GATEWAY_URL"
    echo "   Start it first with: ./scripts/run-local-gateway.sh"
    echo ""
    echo "   Continuing anyway (dashboard will show errors until gateway starts)..."
    echo ""
fi

echo "🎨 Starting AIRS-CP Dashboard on port $DASHBOARD_PORT"
echo "   Gateway URL: $GATEWAY_URL"
echo "   DB Path: $AIRS_DB_PATH"
echo ""
echo "Dashboard: http://localhost:$DASHBOARD_PORT/dashboard"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run dashboard
exec uvicorn airs_cp.dashboard.app:app \
    --host 0.0.0.0 \
    --port "$DASHBOARD_PORT" \
    --log-level info
