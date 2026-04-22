#!/usr/bin/env bash
# lib/helpers.sh

[[ -n "${_HELPERS_SH_LOADED:-}" ]] && return 0
_HELPERS_SH_LOADED=1

_RESET='\033[0m'
_BOLD='\033[1m'
_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_CYAN='\033[0;36m'

info()  { printf "%b\n" "${_CYAN}${_BOLD}[INFO]${_RESET}  $*"; }
ok()    { printf "%b\n" "${_GREEN}${_BOLD}[ OK ]${_RESET}  $*"; }
warn()  { printf "%b\n" "${_YELLOW}${_BOLD}[WARN]${_RESET}  $*"; }
error() { printf "%b\n" "${_RED}${_BOLD}[ERR!]${_RESET}  $*" >&2; }
fail()    { error "$@"; exit 1; }
log_section() { echo ""; }


assert_not_root() {
    [[ "$EUID" -ne 0 ]]
}

command_exists() {
    command -v "$1" &>/dev/null
}

detect_distro() {
    [ -f /etc/os-release ] || return 1
    . /etc/os-release || return 1
    echo "${ID:-}" | grep -q . || return 1
    echo "$ID"
}

join_array() {
    local IFS=","
    echo "$*"
}

install_pkg() {
#   0 = success
#   1 = failed to detect Linux distribution (/etc/os-release missing or invalid)
#   2 = unsupported Linux distribution
#   3 = package manager command failed
    local pkg_manager="${PKG_MANAGER:-}"
    local distro

    if [ -z "$pkg_manager" ]; then
        [ -f /etc/os-release ] || return 1
        . /etc/os-release || return 1
        [ -n "$ID" ] || return 1
        distro="$ID"

        case "$distro" in
            arch|manjaro|endeavouros|cachyos) pkg_manager="pacman" ;;
            fedora|fedora-asahi-remix|rhel|centos) pkg_manager="dnf" ;;
            ubuntu|debian|linuxmint) pkg_manager="apt" ;;
            opensuse-leap|opensuse-tumbleweed) pkg_manager="zypper" ;;
            gentoo) pkg_manager="emerge" ;;
            void) pkg_manager="xbps-install" ;;
            *) return 2 ;;
        esac
    fi

    case "$pkg_manager" in
        pacman)
            sudo pacman -S --noconfirm "$@"
            ;;
        dnf)
            sudo dnf install -y "$@"
            ;;
        apt)
            sudo apt install -y "$@"
            ;;
        zypper)
            sudo zypper install -y "$@"
            ;;
        emerge)
            sudo emerge "$@"
            ;;
        xbps-install)
            sudo xbps-install -y "$@"
            ;;
        *)
            return 2
            ;;
    esac || return 3
}

build_lib() {
#   0 = success
#   1 = failed (invalid args or no downloader)
#   2 = curl failed
#   3 = wget failed
    [ "$#" -eq 2 ] || return 1

    local dest="$1"
    local url="$2"

    local scripts=(
        "helpers.sh"
        "01_packages.sh"
        "02_directories.sh"
        "03_permissions.sh"
        "04_services.sh"
        "05_dotfiles.sh"
        "06_fonts.sh"
        "uninstall.sh"
    )

    for script in "${scripts[@]}"; do
        if [ ! -f "$dest/$script" ]; then
            if command -v curl &>/dev/null; then
                curl -fsL "$url/$script" -o "$dest/$script" || return 2
            elif command -v wget &>/dev/null; then
                wget -q "$url/$script" -O "$dest/$script" || return 3
            else
                return 1
            fi
            chmod +x "$dest/$script"
        fi
    done
}
