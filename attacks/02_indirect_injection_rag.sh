#!/usr/bin/env bash
set -euo pipefail

curl -s http://localhost:30080/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"search malicious document","user_id":"attacker","customer_id":"123"}' | head -200
