#!/bin/bash

# Save log file in the same folder as the script
LOG_FILE="$(dirname "$0")/system_health-info.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

{
echo "==== System Health Check at $DATE ===="

# Uptime and load averages
echo "System Uptime and Load Average:"
uptime
echo "------------------------------------------"

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU_USAGE_INT=${CPU_USAGE%.*}

if [ "$CPU_USAGE_INT" -gt "$CPU_THRESHOLD" ]; then
    echo "ALERT: High CPU usage detected: ${CPU_USAGE}%"
else
    echo "CPU usage is normal: ${CPU_USAGE}%"
fi

# Memory usage
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
MEM_USAGE_INT=${MEM_USAGE%.*}

if [ "$MEM_USAGE_INT" -gt "$MEM_THRESHOLD" ]; then
    echo "ALERT: High Memory usage detected: ${MEM_USAGE}%"
else
    echo "Memory usage is normal: ${MEM_USAGE}%"
fi

# Disk usage
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "ALERT: Disk usage high: ${DISK_USAGE}%"
else
    echo "Disk usage is normal: ${DISK_USAGE}%"
fi

echo "------------------------------------------"

# Zombie/defunct processes
ZOMBIES=$(ps aux | awk '{ if ($8=="Z") { print $0 } }' | wc -l)
echo "Zombie processes: $ZOMBIES"

# Network connectivity test
echo "Network connectivity test (ping 8.8.8.8):"
ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Network is UP"
else
    echo "ALERT: Network seems DOWN"
fi

# Open ports (listening services)
echo "Open listening ports:"
ss -tuln | head -n 10

echo "------------------------------------------"

# Top 5 processes by CPU
echo "Top 5 processes by CPU usage:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory
echo "Top 5 processes by Memory usage:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

echo "System health check completed."
echo "=========================================="
} | tee -a "$LOG_FILE"

echo " Health Status stored in $LOG_FILE"

