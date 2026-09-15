#!/usr/bin/env bash
# verify-baseline.sh — checks whether the RER local baseline is healthy.
# Compares the key endpoints against the "expected correct state" (200).
# Usage: bash verify-baseline.sh [BASE_URL]   (default: http://localhost)
set -uo pipefail

BASE="${1:-http://localhost}"
TIMEOUT=8
fail=0

# path | label | expected code
checks=(
  "/|core-frontend (root)|200"
  "/auth/login|auth-frontend (login)|200"
  "/keycloak/realms/car-dpg/.well-known/openid-configuration|keycloak realm car-dpg|200"
  "/cardpgbackend/actuator/health|core-backend health|200"
  "/calculation-engine/actuator/health|calc-engine health|200"
)

echo "== RER baseline check @ ${BASE} =="
for c in "${checks[@]}"; do
  IFS='|' read -r path label expected <<< "$c"
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "${BASE}${path}" 2>/dev/null)
  if [ "$code" = "$expected" ]; then
    printf "  [OK]   %-32s %s\n" "$label" "$code"
  else
    printf "  [FAIL] %-32s expected=%s got=%s\n" "$label" "$expected" "$code"
    fail=1
  fi
done

echo ""
echo "== Containers (rer-*) =="
if command -v podman >/dev/null 2>&1; then
  podman ps -a --format "{{.Names}}\t{{.Status}}" 2>/dev/null | grep -E "^rer-" | sort || echo "  (no rer-* containers)"
else
  echo "  (podman not found)"
fi

echo ""
if [ "$fail" = "0" ]; then
  echo "RESULT: baseline OK (core flow responding). GeoServer may be crash-looping (does not block auth)."
else
  echo "RESULT: some endpoints are off — see docs/TROUBLESHOOTING.md."
fi
exit "$fail"
