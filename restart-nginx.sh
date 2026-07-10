#!/usr/bin/env bash
# restart-nginx.sh — Bonus task: safely restart Nginx and report status.
# Usage: ./restart-nginx.sh

set -euo pipefail

echo "==> Testing Nginx configuration..."
if ! sudo nginx -t; then
    echo "!! Config test failed. Aborting restart."
    exit 1
fi

echo "==> Restarting Nginx..."
sudo systemctl restart nginx

echo "==> Current status:"
sudo systemctl status nginx --no-pager | head -n 5

echo "==> Done. Nginx restarted at $(date)."
