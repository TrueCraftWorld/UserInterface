#!/usr/bin/env bash
set -euo pipefail

PROFILE_FILE="/etc/profile.d/userinterface_input_profile.sh"
BACKUP_FILE="/etc/profile.d/userinterface_input_profile.sh.bak"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi

if [[ -f "$PROFILE_FILE" && ! -f "$BACKUP_FILE" ]]; then
  cp -a "$PROFILE_FILE" "$BACKUP_FILE"
fi

cat >"$PROFILE_FILE" <<'EOF'
#!/usr/bin/env bash
# UserInterface touch/input profile for ROC-RK3566
# Auto-loaded for interactive shells and launcher scripts that source profile.d.

# Keep evdev transform explicit.
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS="rotate=0"

# Enable input diagnostics when needed (set to false for production log volume).
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-qt.qpa.input=false}"

# Disable QML disk cache for deterministic runtime while validating touch behavior.
export QML_DISABLE_DISK_CACHE="${QML_DISABLE_DISK_CACHE:-1}"
EOF

chmod 0644 "$PROFILE_FILE"
echo "Applied profile: $PROFILE_FILE"
echo "Backup (if created): $BACKUP_FILE"
