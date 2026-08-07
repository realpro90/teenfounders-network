#!/bin/bash
# Health check script for PaperMC containers
PORT="${PORT:-25565}"

if pgrep -x "java" > /dev/null && nc -z 127.0.0.1 "$PORT" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
