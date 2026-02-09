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

# Get port from env or use default
PORT=${AIRS_GATEWAY_PORT:-8080}

echo "🚀 Starting AIRS-CP Gateway on port $PORT"
echo "   Provider: $AIRS_PROVIDER"
echo "   Model: $AIRS_MODEL"
echo "   DB Path: $AIRS_DB_PATH"
echo ""
echo "Gateway API: http://localhost:$PORT"
echo "   Docs:     http://localhost:$PORT/docs"
echo "   Health:   http://localhost:$PORT/health"
echo "   Inventory: http://localhost:$PORT/inventory/providers"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run gateway
exec uvicorn airs_cp.gateway.app:app \
    --host 0.0.0.0 \
    --port "$PORT" \
    --log-level info
