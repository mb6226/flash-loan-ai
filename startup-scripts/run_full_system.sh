#!/bin/bash

# Run the full system skeleton. This script is a placeholder and should be filled for production.
python -m src.ai.inference &
python -m src.blockchain.listeners &
python -m src.blockchain.mempool_monitor &
wait
