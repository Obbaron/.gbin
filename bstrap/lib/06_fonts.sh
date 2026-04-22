#!/usr/bin/env bash
# lib/06_fonts.sh
#
# Usage: 06_fonts.sh <font_name ...>
#   font_name - Nerd Font name(s) to install (e.g. JetBrainsMono)

if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi

source "${SCRIPT_DIR}/lib/helpers.sh"

if [ -z "${1:-}" ]; then
    fail "No fonts provided"
fi

FONTS=("$@")
FONT_DIR="$HOME/.local/share/fonts"

if ! command_exists fc-cache; then
    info "fontconfig not found, installing..."
    install_pkg fontconfig || fail "Failed to install fontconfig"
fi

info "Fetching latest Nerd Fonts release..."
VERSION=$(
    if command_exists curl; then
        curl -fsL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
    elif command_exists wget; then
        wget -qO- "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
    else
        fail "Neither curl nor wget found"
    fi | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])"
) || fail "Failed to fetch Nerd Fonts release version"

info "Latest Nerd Fonts version: $VERSION"
mkdir -p "$FONT_DIR"

for font in "${FONTS[@]}"; do
    info "Installing $font..."
    if command_exists curl; then
        curl -fsL "https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION/$font.tar.xz" \
            -o "/tmp/$font.tar.xz" || fail "Failed to download $font"
    elif command_exists wget; then
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION/$font.tar.xz" \
            -O "/tmp/$font.tar.xz" || fail "Failed to download $font"
    else
        fail "Neither curl nor wget found"
    fi
    tar -xf "/tmp/$font.tar.xz" -C "$FONT_DIR" || fail "Failed to extract $font"
    rm "/tmp/$font.tar.xz"
    ok "$font installed"
done

fc-cache -f "$FONT_DIR" || fail "Failed to update font cache"
ok "Font cache updated"
ok "All fonts installed"
