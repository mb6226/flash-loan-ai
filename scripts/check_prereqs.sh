#!/usr/bin/env bash
# Check prerequisites for running the MVP (Linux/macOS)

set -e

missing=()
command -v node >/dev/null 2>&1 || missing+=("node")
command -v npm >/dev/null 2>&1 || missing+=("npm")
command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || missing+=("python")

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing global tools: ${missing[*]}"
  echo "Please install them before running the MVP."
else
  echo "All global tools found: node, npm, python" 
fi

if [ -f .env ]; then
  echo "Found .env; checking some required keys..."
  for key in INFURA_KEY PRIVATE_KEY WALLET_ADDRESS ETHERSCAN_KEY; do
    if grep -q "^${key}=" .env; then
      echo "  OK: $key"
    else
      echo "  MISSING: $key"
    fi
  done
else
  echo ".env not found. Copy .env.example to .env and add your keys: INFURA_KEY, PRIVATE_KEY, etc."
fi

echo "Done."
