#!/usr/bin/env bash
# Read-only Linux evidence collection for an approved SSM document.
set -u

SERVICE="${1:-nginx}"
WINDOW="${2:-15 minutes ago}"

case "$SERVICE" in
  nginx|httpd|sshd) ;;
  *) echo "Unsupported service: use nginx, httpd or sshd" >&2; exit 2 ;;
esac

echo "== host =="
hostname
echo "== service: $SERVICE =="
timeout 10s systemctl is-active "$SERVICE" || true
echo "== recent journal =="
timeout 10s journalctl -u "$SERVICE" --since "$WINDOW" --no-pager -n 100 || true
echo "== memory (MB) =="
free -m
echo "== filesystem =="
df -hP /
echo "== inode usage =="
df -iP /
