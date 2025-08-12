#!/usr/bin/env bash
set -e

export DISPLAY SCREEN_NUM SCREEN_WHD MT4DIR STARTUP_FILE

XVFB_PID=0
TERMINAL_PID=0
VNC_PID=0

term_handler() {
    echo 'SIGTERM signal received'

    if ps -p $TERMINAL_PID > /dev/null; then
        kill -SIGTERM $TERMINAL_PID
        wait $TERMINAL_PID || true
    fi

    /docker/waitonprocess.sh wineserver

    if ps -p $VNC_PID > /dev/null; then
        kill -SIGTERM $VNC_PID
        wait $VNC_PID || true
    fi

    if ps -p $XVFB_PID > /dev/null; then
        kill -SIGTERM $XVFB_PID
        wait $XVFB_PID || true
    fi

    exit 0
}

trap 'term_handler' SIGTERM

# Start Xvfb
Xvfb $DISPLAY -screen $SCREEN_NUM $SCREEN_WHD \
    +extension GLX \
    +extension RANDR \
    +extension RENDER \
    &> /tmp/xvfb.log &
XVFB_PID=$!
sleep 2

if [ -n "$VNC_PASSWORD" ]; then
    x11vnc -storepasswd "$VNC_PASSWORD" /tmp/vnc.pass
    chmod 600 /tmp/vnc.pass
    x11vnc -bg -rfbauth /tmp/vnc.pass -rfbport 5900 -forever -xkb -o /tmp/x11vnc.log &
    VNC_PID=$!
    sleep 2
else
    echo "VNC_PASSWORD not set, skipping VNC server startup"
    VNC_PID=0
fi

wine "$MT4DIR/terminal.exe" /portable "$STARTUP_FILE" &
TERMINAL_PID=$!

wait $TERMINAL_PID
/docker/waitonprocess.sh wineserver
wait $VNC_PID
wait $XVFB_PID
