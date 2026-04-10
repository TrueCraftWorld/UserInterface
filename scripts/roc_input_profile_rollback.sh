#!/usr/bin/env bash
set -euo pipefail

PROFILE_FILE="/etc/profile.d/userinterface_input_profile.sh"
BACKUP_FILE="/etc/profile.d/userinterface_input_profile.sh.bak"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi

if [[ -f "$BACKUP_FILE" ]]; then
  cp -a "$BACKUP_FILE" "$PROFILE_FILE"
  echo "Rollback done: restored $PROFILE_FILE from backup"
else
  rm -f "$PROFILE_FILE"
  echo "Rollback done: removed $PROFILE_FILE (no backup found)"
fi
