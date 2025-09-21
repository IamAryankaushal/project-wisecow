#!/bin/bash

# App Health Checker - Wisecow

# Application URL 
APP_URL="http://127.0.0.1:4499"

SCRIPT_DIR="$(dirname "$0")"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Timestamped log file
LOG_FILE="$LOG_DIR/app_health_$(date +%Y%m%d_%H%M%S).log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

{
echo "==== Application Health Check at $DATE ===="


STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$APP_URL")
if [ "$STATUS_CODE" -eq 200 ]; then
    echo "Application is UP (HTTP $STATUS_CODE)"
else
    echo "ALERT: Application might be DOWN (HTTP $STATUS_CODE)"
fi

RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$APP_URL")
echo "Response time: ${RESPONSE_TIME}s"

FINAL_URL=$(curl -Ls -o /dev/null -w "%{url_effective}" "$APP_URL")
echo "Final URL after redirects: $FINAL_URL"

echo "HTTP Headers:"
curl -s -D - -o /dev/null "$APP_URL" | head -n 10

echo "Application health check completed."
echo "=========================================="
} | tee "$LOG_FILE"

echo "Application Health Status stored in $LOG_FILE"

