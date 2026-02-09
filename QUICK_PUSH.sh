#!/bin/bash
# Quick GitHub Push Script
# Run this after authenticating with GitHub

set -e

echo "🚀 AIRS-CP GitHub Push Script"
echo "=============================="
echo ""

# Safety checks
echo "🔐 Running safety checks..."
if git status | grep -q ".env.local"; then
    echo "⚠️  WARNING: .env.local will be committed! Aborting."
    exit 1
fi

if git status | grep -q "local-data"; then
    echo "⚠️  WARNING: local-data will be committed! Aborting."
    exit 1
fi

echo "✅ No secrets detected"
echo ""

# Show what will be committed
echo "📋 Files to be committed:"
git status --short | head -20
echo ""
echo "Total files: $(git status --short | wc -l)"
echo ""

read -p "Continue with commit? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Add all files
echo "📦 Adding files..."
git add .

# Create commit
echo "💾 Creating commit..."
git commit -m "Initial commit: Distributed AI security gateway architecture

- Distributed gateway deployment (local + Kubernetes)
- Single pane of glass dashboard
- Inline security proxy for AI workloads
- Attack simulation framework (10 test scripts)
- Kubernetes-native Helm charts
- Enterprise-ready documentation
- No SaaS dependency - fully on-prem capable"

echo ""
echo "✅ Commit created successfully!"
echo ""
echo "📤 Next steps:"
echo ""
echo "1. Authenticate with GitHub (if not done):"
echo "   gh auth login"
echo ""
echo "2. Create repository and push:"
echo "   gh repo create airs-k8s-reference --public --source=. --push"
echo ""
echo "   OR for private repo:"
echo "   gh repo create airs-k8s-reference --private --source=. --push"
echo ""
echo "3. If repo already exists, add remote and push:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/airs-k8s-reference.git"
echo "   git push -u origin master"
echo ""
