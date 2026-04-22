#!/bin/bash
# lib/03_permissions.sh

if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi

source "${SCRIPT_DIR}/lib/helpers.sh"

SKIP_MISSING=false
CREATE_MISSING=false

while [[ "${1:-}" == -* ]]; do
    case "$1" in
        -s|--skip)   SKIP_MISSING=true;   shift ;;
        -c|--create) CREATE_MISSING=true; shift ;;
        *) fail "Unknown flag: $1" ;;
    esac
done

if [ -z "${1:-}" ]; then
    fail "No permissions provided"
fi

info "Setting permissions..."
for pair in "$@"; do
    path="${pair%%:*}"
    mode="${pair##*:}"
    if [ ! -e "$path" ]; then
        if [ "$CREATE_MISSING" = true ]; then
            touch "$path" || fail "Failed to create $path"
        elif [ "$SKIP_MISSING" = true ]; then
            warn "Skipping $path — does not exist"
            continue
        else
            fail "Path does not exist: $path"
        fi
    fi
    chmod "$mode" "$path" || fail "Failed to set permissions on $path"
    ok "Set $mode on $path"
done
ok "All permissions set"
