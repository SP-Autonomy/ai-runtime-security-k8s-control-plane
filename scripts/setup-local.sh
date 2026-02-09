#!/bin/bash
set -e

echo "🚀 AIRS-CP Local Setup"
echo "====================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not found. Please install Python 3.9+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Python $PYTHON_VERSION found"

if ! command -v ollama &> /dev/null; then
    echo "⚠️  Ollama not found. Install from https://ollama.ai"
    echo "   You can still run AIRS-CP with cloud providers (OpenAI, Anthropic, etc.)"
fi

# Navigate to vendor directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$REPO_ROOT/vendor/airs-cp"

if [ ! -d "$VENDOR_DIR" ]; then
    echo "❌ Cannot find vendor/airs-cp directory"
    exit 1
fi

cd "$VENDOR_DIR"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo ""
    echo "🔧 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
pip install -q --upgrade pip
pip install -q -e .

# Create local data directory
mkdir -p "$REPO_ROOT/local-data"

# Create .env.local if it doesn't exist
ENV_FILE="$REPO_ROOT/.env.local"
if [ ! -f "$ENV_FILE" ]; then
    echo ""
    echo "📝 Creating .env.local configuration..."

    # Detect Ollama host
    OLLAMA_HOST="http://localhost:11434"
    if command -v ollama &> /dev/null; then
        if curl -s "$OLLAMA_HOST/api/tags" &> /dev/null; then
            echo "✅ Detected Ollama running at $OLLAMA_HOST"
        else
            echo "⚠️  Ollama installed but not running. Start it with: ollama serve"
        fi
    fi

    cat > "$ENV_FILE" << EOF
# AIRS-CP Local Configuration
# ============================

# Core Settings
# Mode: observe (log only) or enforce (block/sanitize threats)
AIRS_MODE=enforce
AIRS_LOG_LEVEL=INFO

# Provider Configuration
# Options: ollama, openai, anthropic, azure, cohere, mistral
AIRS_PROVIDER=ollama

# Model Selection (change based on your provider)
AIRS_MODEL=llama2

# Ollama Settings (only for ollama provider)
OLLAMA_HOST=$OLLAMA_HOST

# Cloud Provider API Keys (uncomment and set if using cloud providers)
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
# AZURE_OPENAI_KEY=...

# Security Features
AIRS_KILL_SWITCH=false
AIRS_ML_ENABLED=true
AIRS_PII_DETECTION_ENABLED=true
AIRS_INJECTION_DETECTION_ENABLED=true
AIRS_TAINT_TRACKING_ENABLED=true

# Database Path (stores evidence and inventory)
AIRS_DB_PATH=$REPO_ROOT/local-data/evidence.db

# Gateway & Dashboard Ports
AIRS_GATEWAY_PORT=8080
AIRS_DASHBOARD_PORT=8501

# Gateway URL for dashboard (used by dashboard to call gateway)
AIRS_GATEWAY_URL=http://localhost:8080
EOF
    echo "✅ Created $ENV_FILE"
else
    echo "✅ Using existing .env.local"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env.local to configure your provider and API keys"
echo "  2. Start gateway:   ./scripts/run-local-gateway.sh"
echo "  3. Start dashboard: ./scripts/run-local-dashboard.sh"
echo ""
echo "Gateway will run on:   http://localhost:8080"
echo "Dashboard will run on: http://localhost:8501/dashboard"
echo ""
