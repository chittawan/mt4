#!/usr/bin/env bash
set -e

export DISPLAY SCREEN_NUM SCREEN_WHD MT4DIR STARTUP_FILE

XVFB_PID=0
TERMINAL_PID=0

term_handler() {
    echo '########################################'
    echo 'SIGTERM signal received'

    if ps -p $TERMINAL_PID > /dev/null; then
        kill -SIGTERM $TERMINAL_PID
        wait $TERMINAL_PID || true
    fi

    /docker/waitonprocess.sh wineserver

    if ps -p $XVFB_PID > /dev/null; then
        kill -SIGTERM $XVFB_PID
        wait $XVFB_PID || true
    fi

    exit 0
}

trap 'term_handler' SIGTERM

Xvfb $DISPLAY -screen $SCREEN_NUM $SCREEN_WHD \
    +extension GLX \
    +extension RANDR \
    +extension RENDER \
    &> /tmp/xvfb.log &
XVFB_PID=$!
sleep 2

wine "$MT4DIR/terminal.exe" /portable "$STARTUP_FILE" &
TERMINAL_PID=$!

wait $TERMINAL_PID
/docker/waitonprocess.sh wineserver
wait $XVFB_PID
