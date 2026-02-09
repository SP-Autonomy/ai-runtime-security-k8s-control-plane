# AIRS-CP Attack Test Scripts

This directory contains attack simulation scripts for testing AIRS-CP security detection across local and Kubernetes gateways.

## Directory Structure

```
attacks/
├── k8s/          # Attacks targeting Kubernetes gateway (localhost:9080)
├── local/        # Attacks targeting local gateway (localhost:8080)
└── README.md     # This file
```

## Attack Scripts

Each folder contains 5 attack types:

1. **01_prompt_injection.sh** - Tests prompt injection detection
2. **02_pii_leakage.sh** - Tests PII (SSN, credit card) detection
3. **03_data_exfiltration.sh** - Tests data exfiltration attempt detection
4. **04_sql_injection.sh** - Tests SQL injection pattern detection
5. **05_jailbreak.sh** - Tests jailbreak attempt detection

## Usage

### Test Individual Attacks

```bash
# Test local gateway
./attacks/local/01_prompt_injection.sh

# Test K8s gateway
./attacks/k8s/01_prompt_injection.sh
```

### Test All Attacks on Local Gateway

```bash
for script in attacks/local/*.sh; do
  echo "Running: $script"
  bash "$script"
  echo "---"
  sleep 2
done
```

### Test All Attacks on K8s Gateway

```bash
for script in attacks/k8s/*.sh; do
  echo "Running: $script"
  bash "$script"
  echo "---"
  sleep 2
done
```

### Test All Attacks on Both Gateways

```bash
# Comprehensive test
./scripts/test-all-distributed.sh
```

## Expected Results

✅ **Blocked Attacks:**
- Prompt injection → "Request blocked due to security policy violation"
- Jailbreak attempts → "Request blocked due to security policy violation"

✅ **Sanitized/Safe Responses:**
- PII leakage → Model refuses to process sensitive data
- Data exfiltration → Model refuses malicious requests
- SQL injection → Model provides educational response without execution

## Monitoring

All detected attacks appear in:
- **Dashboard:** http://localhost:8501/dashboard
- **Monitor Tab:** Real-time alerts
- **Evidence Tab:** Detailed attack logs with risk scores

## Legacy Scripts

The root `attacks/` directory contains legacy scripts (`01_prompt_injection.sh`, etc.) that target the old `localhost:30080/chat` endpoint. These are preserved for backward compatibility but are not actively used in the current distributed architecture.
