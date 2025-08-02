#!/bin/bash
set -e

MT4_PATH="C:\\root\\mt4\\terminal.exe"
CONFIG_PATH="C:\\root\\config\\start.ini"

echo "[INFO] Starting MetaTrader 4 Portable..."
wine "$MT4_PATH" /portable /config:$CONFIG_PATH &

# Health check loop
while true; do
    if ! pgrep -f "terminal.exe" > /dev/null; then
        echo "[ERROR] MT4 stopped. Exiting..."
        exit 1
    fi
    sleep 10
done
