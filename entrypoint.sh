#!/bin/bash
set -e

echo "Starting cron-runner container..."

# Set proper permissions for scripts directory
if [ -d "/scripts" ]; then
    echo "Setting permissions for /scripts directory..."
    chmod -R 755 /scripts
    find /scripts -type f -name "*.sh" -exec chmod +x {} \;
fi

# Set proper permissions for cron.d files
if [ -d "/etc/cron.d" ]; then
    echo "Setting permissions for cron.d files..."
    chmod -R 644 /etc/cron.d/*
fi

# Start cron in foreground
echo "Starting cron daemon..."
crond -f -l 2
