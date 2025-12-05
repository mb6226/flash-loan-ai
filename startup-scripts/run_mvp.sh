#!/bin/bash
echo "🚀 Flash Loan AI MVP Boot Sequence..."

# If it's a first-time install, install Node & Python packages
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install || { echo "npm install failed"; exit 1; }
    # Prefer python -m pip for robust invocation
    if command -v python >/dev/null 2>&1; then
      python -m pip install -r requirements.txt || { echo "pip install failed"; exit 1; }
    else
      pip install -r requirements.txt || { echo "pip install failed"; exit 1; }
    fi
fi

# Compile contracts
echo "🔨 Compiling contracts..."
npx hardhat compile || { echo "Hardhat compile failed"; exit 1; }

# Run the MVP
echo "🎯 Starting MVP bot..."
node src/startup-scripts/run_mvp.js || {
    echo "❌ Error detected. Check logs/data/logs/ for details"
    exit 1
}
#!/usr/bin/env bash
# Run the MVP: start inference (Python) + listeners (Node) + mempool (Node) in background
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

# ensure logs
LOG_DIR="$ROOT_DIR/data/logs"
mkdir -p "$LOG_DIR"

# load .env into the environment if present
if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1091
  set -o allexport
  # shellcheck disable=SC1090
  . "$ROOT_DIR/.env"
  set +o allexport
else
  echo "Warning: .env not found. Expected at $ROOT_DIR/.env" >&2
fi

check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: Required command '$1' is not installed or available in PATH" >&2
    exit 1
  fi
}

check_cmd node
check_cmd npm
check_cmd python || check_cmd python3

PIDFILE="$ROOT_DIR/.mvp_pids"
rm -f "$PIDFILE"

start_process() {
  local name="$1"; shift
  local cmd=("$@")
  local logfile="$LOG_DIR/${name}.log"
  echo "Starting $name -> $logfile"
  # Launch in background
  "${cmd[@]}" >>"$logfile" 2>&1 &
  echo $! >>"$PIDFILE"
}

cleanup() {
  echo "Shutting down MVP..."
  if [ -f "$PIDFILE" ]; then
    while read -r pid; do
      if kill -0 "$pid" >/dev/null 2>&1; then
        echo "Killing process $pid";
        kill -TERM "$pid" || true
      fi
    done <"$PIDFILE"
  fi
  rm -f "$PIDFILE"
  exit 0
}

trap cleanup SIGINT SIGTERM

echo "MVP startup: starting components in background. Logs: $LOG_DIR"

# Start Python inference (if file exists)
if [ -f "$ROOT_DIR/src/ai/inference.py" ]; then
  # Use python launcher or python3
  if command -v python >/dev/null 2>&1; then
    PYEXEC=python
  else
    PYEXEC=python3
  fi
  start_process "inference" "$PYEXEC" -m src.ai.inference
else
  echo "Warning: Python inference script not found: src/ai/inference.py" >&2
fi

# Start Node listeners
if [ -f "$ROOT_DIR/src/blockchain/listeners.js" ]; then
  start_process "listeners" node src/blockchain/listeners.js
else
  echo "Warning: Node listener not found: src/blockchain/listeners.js" >&2
fi

# Start Node mempool monitor (optional)
if [ -f "$ROOT_DIR/src/blockchain/mempool_monitor.js" ]; then
  start_process "mempool" node src/blockchain/mempool_monitor.js
fi

echo "Components started. Monitor logs with: tail -f $LOG_DIR/*.log"
echo "Press Ctrl+C to stop and cleanup." 

# Wait for background processes (until killed)
while true; do
  sleep 1 && wait
done
