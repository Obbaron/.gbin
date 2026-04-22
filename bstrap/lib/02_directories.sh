#!/bin/bash
# lib/02_directories.sh

if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi

source "${SCRIPT_DIR}/lib/helpers.sh"

if [ -z "${1:-}" ]; then
    fail "No directories provided"
fi

DIRECTORIES=("$@")

info "Creating directories..."
for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "$dir" || fail "Failed to create directory: $dir"
    ok "Created directory: $dir"
done
ok "All directories created"
