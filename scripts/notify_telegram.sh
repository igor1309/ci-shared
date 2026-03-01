#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: notify_telegram.sh <token> <chat_id> <chunk1> [chunk2...]" >&2
  exit 2
fi

token="$1"
chat_id="$2"
shift 2

for chunk in "$@"; do
  curl -fsS --connect-timeout 5 --max-time 20 --retry 3 --retry-delay 1 --retry-all-errors -X POST "https://api.telegram.org/bot${token}/sendMessage" -d "chat_id=${chat_id}" --data-urlencode "text=${chunk}"
done
