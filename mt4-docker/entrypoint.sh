#!/bin/bash
set -e

# เริ่ม X Virtual Framebuffer
Xvfb :0 -screen 0 1024x768x16 &
sleep 3

CONFIG_PATH="C:\\users\\trader\\config\\start.ini"
MT4_PATH="C:\\Program Files\\MetaTrader 4\\terminal.exe"

echo "[INFO] Starting MetaTrader 4 with EA..."
wine "$MT4_PATH" /portable /config:$CONFIG_PATH &

# Health check loop: ถ้า MT4 ตาย ให้ exit container
while true; do
    if ! pgrep -f "terminal.exe" > /dev/null; then
        echo "[ERROR] MT4 process stopped. Exiting..."
        exit 1
    fi
    sleep 10
done
