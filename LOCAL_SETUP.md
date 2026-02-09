# AIRS-CP Local Setup

Run AIRS-CP on your laptop to protect local Ollama models or connect to cloud LLM providers.

## Quick Start

### 1. Run Setup (One Time)

```bash
./scripts/setup-local.sh
```

This will:
- ✅ Check Python 3.9+ is installed
- ✅ Create a Python virtual environment
- ✅ Install all dependencies
- ✅ Create `.env.local` configuration file
- ✅ Create `local-data/` directory for database

### 2. Configure Your Provider

Edit `.env.local` to set your provider and credentials:

```bash
# For local Ollama (default)
AIRS_PROVIDER=ollama
AIRS_MODEL=llama2
OLLAMA_HOST=http://localhost:11434

# OR for OpenAI
AIRS_PROVIDER=openai
AIRS_MODEL=gpt-4
OPENAI_API_KEY=sk-...

# OR for Anthropic
AIRS_PROVIDER=anthropic
AIRS_MODEL=claude-3-5-sonnet-20241022
ANTHROPIC_API_KEY=sk-ant-...
```

### 3. Start Services

**Option A: Run both services at once (recommended)**
```bash
./scripts/run-local-all.sh
```

**Option B: Run in separate terminals**
```bash
# Terminal 1 - Gateway
./scripts/run-local-gateway.sh

# Terminal 2 - Dashboard
./scripts/run-local-dashboard.sh
```

### 4. Access Your Services

- **Gateway API**: http://localhost:8080
  - API Docs: http://localhost:8080/docs
  - Health Check: http://localhost:8080/health
  - Inventory: http://localhost:8080/inventory/providers

- **Dashboard**: http://localhost:8501/dashboard

### 5. Stop Services

```bash
./scripts/stop-local.sh
```

---

## Using with Your Ollama Models

### If Ollama is Running

1. Check your models:
   ```bash
   ollama list
   ```

2. Set your default model in `.env.local`:
   ```bash
   AIRS_MODEL=llama2  # or whatever model you have
   ```

3. Start AIRS-CP:
   ```bash
   ./scripts/run-local-all.sh
   ```

4. Your models are now protected! Use the gateway endpoint instead of direct Ollama:
   ```bash
   # Instead of: curl http://localhost:11434/v1/chat/completions
   # Use:
   curl http://localhost:8080/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "llama2",
       "messages": [{"role": "user", "content": "Hello!"}]
     }'
   ```

5. View your models in the dashboard:
   - Go to http://localhost:8501/dashboard/inventory
   - Click "🔄 Refresh Inventory" to discover your Ollama models
   - See them listed with "💻 local" environment badge

---

## Configuration Options

All settings are in `.env.local`:

### Provider Settings
```bash
AIRS_PROVIDER=ollama|openai|anthropic|azure|cohere|mistral
AIRS_MODEL=<model-name>
```

### Ollama Settings
```bash
OLLAMA_HOST=http://localhost:11434
```

### Cloud Provider Keys
```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
AZURE_OPENAI_ENDPOINT=https://...
AZURE_OPENAI_KEY=...
```

### Security Features
```bash
AIRS_ML_ENABLED=true                    # Enable ML-based detection
AIRS_PII_DETECTION_ENABLED=true         # Detect PII in requests/responses
AIRS_INJECTION_DETECTION_ENABLED=true   # Detect prompt injection
AIRS_TAINT_TRACKING_ENABLED=true        # Track data flow
AIRS_KILL_SWITCH=false                  # Emergency kill switch
```

### Ports
```bash
AIRS_GATEWAY_PORT=8080      # Gateway API port
AIRS_DASHBOARD_PORT=8501    # Dashboard UI port
```

---

## Running Alongside Kubernetes

The local setup **does not interfere** with your Kubernetes deployment. They are completely independent:

- **Kubernetes**: Uses containerized images and cluster-internal services
- **Local**: Uses Python virtual environment and localhost

You can:
- Run local AIRS-CP to protect your laptop's Ollama models
- Run Kubernetes AIRS-CP to protect production/cloud models
- Switch between them by changing ports or endpoints

---

## Distributed Environments (POV Scenario)

To extend visibility across multiple environments:

### Scenario 1: Multiple Local Installations
- Install AIRS-CP on multiple developer laptops
- Each protects their local Ollama models
- Each has its own dashboard showing local models
- Aggregate evidence by collecting DB files: `local-data/evidence.db`

### Scenario 2: Hybrid (Local + Kubernetes)
- Run AIRS-CP locally for development/testing
- Run AIRS-CP in Kubernetes for production
- Each instance has separate inventory showing deployment environment
- Both feed evidence to centralized SIEM/logging

### Scenario 3: Multiple Kubernetes Clusters
- Deploy AIRS-CP to each cluster
- Each instance auto-detects its environment (AWS, Azure, GCP, etc.)
- Models show with appropriate environment badges
- Service mesh routes traffic through respective gateways

---

## Troubleshooting

### Ollama Not Found
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull a model
ollama pull llama2

# Verify it's running
ollama list
curl http://localhost:11434/api/tags
```

### Port Already in Use
Change ports in `.env.local`:
```bash
AIRS_GATEWAY_PORT=8081
AIRS_DASHBOARD_PORT=8502
```

### Gateway Not Responding
Check if it's running:
```bash
curl http://localhost:8080/health

# If not, check logs (if running in background)
tail -f /tmp/airs-gateway.log
```

### Dashboard Shows Connection Error
Ensure gateway is running first:
```bash
./scripts/run-local-gateway.sh  # Start this first
# Then in another terminal:
./scripts/run-local-dashboard.sh
```

### Models Not Appearing in Inventory
1. Click "🔄 Refresh Inventory" in dashboard
2. Check Ollama is running: `ollama list`
3. Verify `OLLAMA_HOST` in `.env.local` matches your Ollama server

---

## Development Workflow

### Making Code Changes

1. Edit code in `vendor/airs-cp/src/`
2. Stop services: `./scripts/stop-local.sh`
3. Restart: `./scripts/run-local-all.sh`
4. Changes are immediately active (no Docker rebuild needed!)

### Testing with Different Providers

Edit `.env.local` and change `AIRS_PROVIDER`:

```bash
# Test with Ollama
AIRS_PROVIDER=ollama
AIRS_MODEL=llama2

# Test with OpenAI
AIRS_PROVIDER=openai
AIRS_MODEL=gpt-4

# Restart services
./scripts/stop-local.sh && ./scripts/run-local-all.sh
```

### Viewing Evidence Database

```bash
sqlite3 local-data/evidence.db

# List models
SELECT model_id, provider, deployment_env, status FROM model_inventory;

# Check evidence
SELECT * FROM evidence LIMIT 10;
```

---

## Next Steps

- ✅ Configure your provider in `.env.local`
- ✅ Start services with `./scripts/run-local-all.sh`
- ✅ Visit dashboard at http://localhost:8501/dashboard
- ✅ Test a request through the gateway
- ✅ View detection results in the Evidence tab
- ✅ Explore your model inventory

For production deployment, see the main [README.md](README.md) for Kubernetes setup.
