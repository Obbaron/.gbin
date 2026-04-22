#!/usr/bin/env bash
# lib/01_packages.sh

PKG_MANAGER="${PKG_MANAGER:-}"

if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi

source "${SCRIPT_DIR}/lib/helpers.sh"

if [ -z "${1:-}" ]; then
    fail "No packages provided"
fi

PACKAGES=("$@")

info "Installing packages: ${PACKAGES[*]}..."
install_pkg "${PACKAGES[@]}"
case $? in
    0) ok "All packages installed" ;;
    1) fail "Failed to detect Linux distribution" ;;
    2) fail "Unsupported Linux distribution" ;;
    3) fail "Package manager command failed" ;;
esac
