#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <app_binary> <output_log>"
  echo "Example: $0 ./UserInterface /tmp/ui_keyboard.log"
  exit 1
fi

APP_BIN="$1"
OUT_LOG="$2"

export QT_LOGGING_RULES="qt.qpa.input=true;qt.quick.pointer=true;qt.quick.events=true"
export QML_DISABLE_DISK_CACHE=1

echo "Writing log to: $OUT_LOG"
echo "Press Ctrl+C to stop capture."

"$APP_BIN" 2>&1 | tee "$OUT_LOG"
