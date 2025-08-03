#!/bin/bash
set -e
Xvfb :99 -screen 0 1024x768x16 &
export DISPLAY=:99
sleep 3
echo "[INFO] Starting MetaTrader 4..."
wine "C:\\Program Files\\MetaTrader 4\\terminal.exe" /portable &
wait
