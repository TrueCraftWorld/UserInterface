#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
IFACE="${UPLOAD_IFACE:-wlan0}"
PORT="${UPLOAD_PORT:-57891}"
COMMENT="${UPLOAD_RULE_COMMENT:-ui-upload-guard}"

if ! command -v ufw >/dev/null 2>&1; then
  echo "ufw not found" >&2
  exit 1
fi

if [[ "$ACTION" != "open" && "$ACTION" != "close" ]]; then
  echo "Usage: $0 <open|close>" >&2
  exit 2
fi

delete_rules() {
  while ufw status numbered | grep -q "$COMMENT"; do
    local n
    n=$(ufw status numbered | grep "$COMMENT" | head -n1 | sed -E 's/^\[ *([0-9]+)\].*/\1/')
    [[ -z "$n" ]] && break
    ufw --force delete "$n" >/dev/null
  done
}

if [[ "$ACTION" == "close" ]]; then
  delete_rules
  exit 0
fi

CIDR=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}' | head -n1 || true)
if [[ -z "$CIDR" ]]; then
  echo "No IPv4 on interface $IFACE" >&2
  exit 3
fi

RULE_NET=$(python3 - "$CIDR" <<'PY'
import ipaddress
import sys
cidr = sys.argv[1]
net = ipaddress.ip_interface(cidr).network
print(f"{net.network_address}/{net.prefixlen}")
PY
)

delete_rules
ufw allow from "$RULE_NET" to any port "$PORT" proto tcp comment "$COMMENT" >/dev/null

exit 0
