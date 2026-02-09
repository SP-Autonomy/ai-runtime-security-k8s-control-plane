# AIRS-CP: Distributed AI Security Gateway Architecture

**Enterprise-Grade AI Security for On-Premises and Kubernetes Deployments**

AIRS-CP (AI Request Security - Control Plane) provides inline security for AI workloads through distributed gateway deployment. Protect your AI infrastructure—whether on-premises, Kubernetes, cloud, or hybrid—without exposing your environment to external SaaS platforms.

---

## 🎯 Why AIRS-CP?

Most AI security solutions require sending data to external SaaS platforms, creating:
- **Privacy concerns** - Your prompts and responses leave your infrastructure
- **Compliance issues** - Data residency and regulatory requirements violated
- **Latency overhead** - Additional network hops for every AI request
- **Vendor lock-in** - Dependency on external services for critical security

**AIRS-CP is different**: Deploy security gateways directly in your infrastructure—inline, on-prem, and fully under your control.

---

## 🏗️ Architecture Overview

### Distributed Gateway + Single Pane of Glass

```
┌────────────────────────────────────────────────────┐
│         Unified Security Dashboard                 │
│         (Single Pane of Glass)                     │
│  • Real-time monitoring across all environments    │
│  • Centralized policy management                   │
│  • Unified threat intelligence                     │
└────────────────────────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                  │
        ▼                                  ▼
┌────────────────┐              ┌────────────────────┐
│ Local Gateway  │              │ Kubernetes Gateway │
│ (On-Premises)  │              │ (Cloud/K8s)        │
├────────────────┤              ├────────────────────┤
│ • Local LLM     │              │ • K8s-native pods  │
│ • Private LLMs │              │ • Cluster    │
│ • Edge deploy  │              │ • Namespace-scoped │
└────────────────┘              └────────────────────┘
        │                                  │
        ▼                                  ▼
   AI Workloads                      AI Workloads
  (Secured In-Line)               (Secured In-Cluster)
```

### How It Works: Inline Proxy/API Gateway

AIRS-CP operates as an **inline security proxy** that sits between your applications and AI models:

1. **Your Application** → Makes OpenAI-compatible API call
2. **AIRS Gateway** (inline proxy) → Intercepts, inspects, and secures the request:
   - Detects PII, secrets, prompt injection attacks
   - Applies security policies (block, sanitize, alert)
   - Tracks evidence and generates audit logs
3. **AI Model** (Ollama/OpenAI/Anthropic/etc.) → Receives cleaned request
4. **AIRS Gateway** → Secures response before returning
5. **Your Application** → Receives safe, policy-compliant response

**Zero code changes required** - Simply point your API endpoint to the AIRS gateway.

---

## ✨ Key Features

### 🔒 Enterprise Security
- **PII Detection & Redaction** - Prevent sensitive data leakage (SSN, credit cards, emails)
- **Prompt Injection Defense** - Block jailbreaks and adversarial attacks
- **Taint Tracking** - Monitor data flow across AI interactions
- **Command Injection Prevention** - Detect malicious code execution attempts
- **Kill Switch** - Instant emergency shutdown of AI traffic

### 🌐 Distributed Architecture
- **Multi-Gateway Support** - Deploy across on-prem, Kubernetes, cloud, edge
- **Single Dashboard** - Unified monitoring for all gateways
- **Independent Operation** - Each gateway autonomous with local database
- **Graceful Degradation** - System continues if one gateway fails
- **Horizontal Scaling** - Add gateways as infrastructure grows

### ☸️ Kubernetes-Native
- **Helm Charts** - Production-ready deployments
- **StatefulSet Support** - Persistent evidence storage
- **Service Mesh Compatible** - Works with Istio, Linkerd
- **Namespace Isolation** - Deploy per-namespace or cluster-wide
- **ConfigMap/Secret Integration** - Cloud-native configuration

### 🎨 Unified Dashboard
- **Real-Time Monitoring** - Live attack detection across all gateways
- **Evidence Explorer** - Detailed forensics for security incidents
- **Model Inventory** - Track all AI models across environments
- **Quick Actions** - Set modes, toggle kill switch, manage policies
- **Environment Badges** - Visual distinction of local vs. Kubernetes vs. cloud

### 🔌 Provider Agnostic
- **Ollama** (on-prem LLMs)
- **OpenAI** (GPT-4, GPT-3.5)
- **Anthropic** (Claude)
- **Azure OpenAI**
- **Cohere, Mistral, and more**

---

### Risk Mapping

#### GOVERN
- Policies as runtime configuration: mode (observe/enforce), detectors on/off, kill switch.
- Evidence + dashboard support accountability and oversight.

#### MAP
- Provider abstraction + (planned) model inventory help map system context: which models, where hosted, which endpoints.

#### MEASURE
- PII + injection detectors + taint tracking generate measurable signals.
- Metrics endpoint supports continuous measurement (requests, detections, blocks).

#### MANAGE
- Enforcement actions (block/redact/allow) + kill switch support risk treatment.
- Evidence DB supports audits, incident triage, and control effectiveness tracking.

#### OWASP
- “Runtime guardrails at the inference boundary aligned to OWASP LLM01/06.”
- “Continuous monitoring and evidence logging aligned to NIST AI RMF Measure/Manage.”
- “Operational controls (observe/enforce, kill switch) that support EU AI Act-style logging, oversight, and incident response readiness.”
- “Detection/containment at a choke point aligned to MITRE ATLAS prompt-driven attack patterns.”

## 🚀 Quick Start

### Prerequisites
- **Local Deployment**: Docker, Ollama, Python 3.10+
- **Kubernetes Deployment**: kind/k3s/k8s cluster, kubectl, helm

### 1. Local Gateway (On-Premises)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/airs-k8s-reference.git
cd airs-k8s-reference

# Setup and start local gateway
./scripts/setup-local.sh
./scripts/run-local-gateway.sh

# In another terminal, start dashboard
./scripts/run-local-dashboard.sh
```

**Access:** http://localhost:8501/dashboard

### 2. Kubernetes Gateway

```bash
# Create kind cluster (or use existing K8s)
kind create cluster --name airs-demo

# Deploy AIRS-CP gateway to Kubernetes
kubectl create namespace ai-security
helm install airs-cp ./helm/airs-cp -n ai-security

# Deploy Ollama in cluster (optional)
kubectl create namespace ai-app
kubectl apply -f helm/ollama/ollama.yaml

# Verify deployment
kubectl get pods -n ai-security
```

### 3. Distributed Architecture (Local + K8s)

```bash
# Start both gateways + unified dashboard
./scripts/start-distributed.sh

# Access unified dashboard
open http://localhost:8501/dashboard
```

**Dashboard aggregates data from:**
- Local gateway (localhost:8080)
- Kubernetes gateway (localhost:9080 via port-forward)

---

## 📊 Testing Security Detection

### Run Attack Simulations

```bash
# Test local gateway
./attacks/local/01_prompt_injection.sh
./attacks/local/02_pii_leakage.sh

# Test Kubernetes gateway
./attacks/k8s/01_prompt_injection.sh
./attacks/k8s/05_jailbreak.sh

# Test all attacks across both gateways
./scripts/test-all-distributed.sh
```

**View Results:** Dashboard → Monitor tab → Real-time alerts

---

## 🏢 Enterprise Deployment Benefits

| Feature | AIRS-CP (This Project) | Traditional SaaS Security |
|---------|------------------------|---------------------------|
| **Data Privacy** | ✅ All data stays in your infrastructure | ❌ Data sent to external SaaS |
| **Latency** | ✅ Inline - no external calls | ❌ Additional network hops |
| **Compliance** | ✅ Full control over data residency | ⚠️ Depends on SaaS provider |
| **Deployment** | ✅ On-prem, K8s, cloud, hybrid | ❌ SaaS-only |
| **Air-Gapped Support** | ✅ Yes - fully offline capable | ❌ Requires internet |
| **Vendor Lock-In** | ✅ Open architecture | ⚠️ Proprietary SaaS |
| **Cost Model** | ✅ Fixed - infrastructure costs only | ❌ Variable - per-request pricing |
| **Customization** | ✅ Full source code access | ❌ Limited API configuration |

---

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env.local` and customize:

```bash
# Security Mode
AIRS_MODE=enforce                    # observe (log only) or enforce (block)

# Provider Selection
AIRS_PROVIDER=ollama                 # ollama, openai, anthropic, azure
AIRS_MODEL=llama3.2:1b

# Security Features
AIRS_PII_DETECTION_ENABLED=true
AIRS_INJECTION_DETECTION_ENABLED=true
AIRS_TAINT_TRACKING_ENABLED=true

# Distributed Architecture
AIRS_GATEWAY_URLS=http://localhost:8080,http://localhost:9080
```

### Kubernetes Configuration

Edit `helm/airs-cp/values-kind.yaml`:

```yaml
gateway:
  mode: enforce
  replicas: 2                        # Scale horizontally
  securityPolicies:
    piiDetection: true
    injectionPrevention: true
```

---

## 📁 Project Structure

```
airs-k8s-reference/
├── helm/                    # Kubernetes Helm charts
│   ├── airs-cp/            # Gateway + Dashboard deployment
│   └── ollama/             # Ollama LLM deployment
├── scripts/                # Automation scripts
│   ├── setup-local.sh      # Local environment setup
│   ├── start-distributed.sh # Start all services
│   └── test-*.sh           # Security test suites
├── attacks/                # Attack simulation scripts
│   ├── local/              # Local gateway tests
│   └── k8s/                # Kubernetes gateway tests
├── clusters/               # kind cluster configs
├── demos/                  # Screenshots and demos
└── vendor/airs-cp/         # AIRS-CP security engine (submodule)
```

---

## 🛡️ Security Detection Capabilities

### Threats Detected
- **Prompt Injection** - "Ignore previous instructions..."
- **PII Leakage** - SSN, credit cards, emails, phone numbers
- **Data Exfiltration** - Attempts to send data to external URLs
- **SQL Injection Patterns** - "OR 1=1", "DROP TABLE"
- **Command Injection** - Shell commands, file system access
- **Jailbreak Attempts** - "Developer mode", role manipulation
- **Secrets Exposure** - API keys, tokens, passwords

### Security Actions
- **Block** - Reject malicious requests with error
- **Sanitize** - Redact sensitive data before processing
- **Alert** - Log to dashboard with risk score
- **Audit** - Store evidence for compliance

---

## 📈 Monitoring & Observability

### Dashboard Features
- **Monitor** - Real-time threat & anomaly detection across all gateways
- **Evidence** - Detailed attack logs with risk scoring
- **Inventory** - Track all AI models and providers
- **Quick Actions** - Toggle modes, kill switch, policies

### Metrics & Logging
- Evidence stored in SQLite (upgradeable to Postgres)
- Structured logging with risk scores
- OpenTelemetry compatible (roadmap)

---

## 🔄 Roadmap

- [ ] PostgreSQL backend for enterprise scale
- [ ] OpenTelemetry metrics export
- [ ] Advanced ML-based threat detection
- [ ] Policy-as-code (OPA integration)
- [ ] Multi-cluster federation
- [ ] SAML/OIDC authentication
- [ ] Response filtering and content moderation

---

## 📝 License

This project is licensed under the Apache License 2.0 - see [LICENSE](LICENSE) file for details.

---

## 📚 Documentation

- **[Local Setup Guide](LOCAL_SETUP.md)** - Detailed local deployment instructions
- **[Attack Testing Guide](attacks/README.md)** - Security testing documentation
- **[Kubernetes Deployment](helm/airs-cp/README.md)** - Production K8s guide

---
