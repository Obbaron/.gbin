#!/bin/bash
# lib/04_services.sh

if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi

source "${SCRIPT_DIR}/lib/helpers.sh"

SKIP_MISSING=false

while [[ "${1:-}" == -* ]]; do
    case "$1" in
        -s|--skip) SKIP_MISSING=true; shift ;;
        *) fail "Unknown flag: $1" ;;
    esac
done

if [ -z "${1:-}" ]; then
    fail "No services provided"
fi

SERVICES=("$@")

info "Enabling services..."
for svc in "${SERVICES[@]}"; do
    if ! systemctl list-unit-files | grep -q "^$svc"; then
        if [ "$SKIP_MISSING" = true ]; then
            warn "Service $svc not found, skipping..."
            continue
        else
            fail "Service $svc not found"
        fi
    fi
    sudo systemctl enable --now "$svc" || fail "Failed to enable service: $svc"
    ok "Enabled $svc"
done
ok "All services enabled"
