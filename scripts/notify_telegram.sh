#!/usr/bin/env bash
# Telegram transport: send one or more message chunks to a bot/chat.
# Chunks are delivered sequentially in argument order. Fail-fast on
# first error; partial delivery is accepted.
#
# Usage: notify_telegram.sh <token> <chat_id> <chunk1> [chunk2...]
#
# Environment:
#   TELEGRAM_PARSE_MODE  — optional; Markdown | MarkdownV2 | HTML.
#                          When set, adds parse_mode to the API call.
#                          Default: unset (plain text).
#
# Caller is responsible for message formatting, splitting, and
# choosing which bot/chat to use.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: notify_telegram.sh <token> <chat_id> <chunk1> [chunk2...]" >&2
  exit 2
fi

token="$1"
chat_id="$2"
shift 2

parse_mode_args=()
if [ -n "${TELEGRAM_PARSE_MODE:-}" ]; then
  parse_mode_args=(--data-urlencode "parse_mode=${TELEGRAM_PARSE_MODE}")
fi

for chunk in "$@"; do
  curl -fsS --connect-timeout 5 --max-time 20 --retry 3 --retry-delay 1 --retry-all-errors -X POST "https://api.telegram.org/bot${token}/sendMessage" -d "chat_id=${chat_id}" "${parse_mode_args[@]}" --data-urlencode "text=${chunk}"
done
