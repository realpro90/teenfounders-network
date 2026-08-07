#!/bin/bash
# ==============================================================================
# Healthcheck Script for Railway / Docker
# Checks TCP 25565 connectivity and validates paper process execution
# ==============================================================================

PORT="${PORT:-25565}"

# Check if Java process is running
if ! pgrep -x "java" > /dev/null; then
    echo "HEALTHCHECK FAILED: Java process not running."
    exit 1
fi

# Check if port 25565 is listening
if nc -z 127.0.0.1 "$PORT" > /dev/null 2>&1; then
    echo "HEALTHCHECK PASSED: Server listening on port $PORT."
    exit 0
else
    echo "HEALTHCHECK WARNING: Port $PORT not accepting connections yet."
    exit 1
fi
