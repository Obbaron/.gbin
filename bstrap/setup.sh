#!/usr/bin/env sh
# setup.sh - Sets up bstrap

GIT_REPO_DEFAULT="https://github.com/Obbaron/.gbin.git"
BRANCH_DEFAULT="main"
BSTRAP_DIR_DEFAULT="bstrap"

download_file() {
  url="$1"
  output="$2"
  tmp="${output}.tmp"
  trap 'rm -f "$tmp"' INT TERM HUP
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL \
      --retry 3 \
      --retry-delay 1 \
      --retry-connrefused \
      "$url" -o "$tmp" || { rm -f "$tmp"; return 1; }
  elif command -v wget >/dev/null 2>&1; then
    wget -q \
      --tries=3 \
      --wait=1 \
      -O "$tmp" "$url" || { rm -f "$tmp"; return 1; }
  else
    echo "Error: neither curl nor wget installed" >&2
    return 1
  fi
  mv -f "$tmp" "$output"
  trap - INT TERM HUP
}

normalize_github_url() {
  repo="$1"
  case "$repo" in
    git@github.com:*)
      repo="${repo#git@github.com:}"
      repo="https://github.com/${repo}"
      ;;
  esac
  repo="${repo%/}"
  repo="${repo#http://github.com/}"
  repo="${repo#https://github.com/}"
  repo="https://raw.githubusercontent.com/${repo}"
  repo="${repo%.git}"
  printf '%s\n' "$repo"
}

require_arg() {
  [ -z "$2" ] && { echo "Error: $1 requires a value" >&2; exit 1; }
}

usage() {
  cat << EOF
Usage: $(basename "$0") [flags] [target-dir]

Flags:
  -h, --help              Show this help message
  -k, --keep              Do not delete this script after running
  -f, --force             Overwrite existing files (excludes bstrap.yaml)
  -r, --repo <url>        GitHub repo URL (default: $GIT_REPO_DEFAULT)
  -b, --branch <name>     Branch to use (default: $BRANCH_DEFAULT)
  -d, --dir <name>        Subdirectory within repo (default: $BSTRAP_DIR_DEFAULT)
  --                      End of flags

Examples:
  $(basename "$0")
  $(basename "$0") /custom/path
  $(basename "$0") --repo https://github.com/user/repo.git
  $(basename "$0") -r git@github.com:user/repo.git -b dev -d tools -k /custom/path
  $(basename "$0") -- --unusual-dirname
EOF
}

main() {
  SELF_DELETE=true
  FORCE=false

  while [ "${1#-}" != "$1" ]; do
    case "$1" in
      -h|--help)   usage; exit 0 ;;
      -k|--keep)   SELF_DELETE=false ;;
      -f|--force)  FORCE=true ;;
      -r|--repo)   shift; require_arg "--repo" "$1";   GIT_REPO="$1" ;;
      -b|--branch) shift; require_arg "--branch" "$1"; BRANCH="$1" ;;
      -d|--dir)    shift; require_arg "--dir" "$1";    BSTRAP_DIR="$1" ;;
      --)          shift; break ;;
      *)           echo "Unknown flag: $1" >&2; exit 1 ;;
    esac
    shift
  done

  GIT_REPO="${GIT_REPO:-$GIT_REPO_DEFAULT}"
  BRANCH="${BRANCH:-$BRANCH_DEFAULT}"
  BSTRAP_DIR="${BSTRAP_DIR:-$BSTRAP_DIR_DEFAULT}"

  RAW_URL=$(normalize_github_url "$GIT_REPO")
  RAW_URL="${RAW_URL}/${BRANCH}${BSTRAP_DIR:+/${BSTRAP_DIR}}"
  TARGET_DIR="${1:-$HOME/.local/bin/bstrap}"

  mkdir -p "$TARGET_DIR"
  DIR_NAME=$(
    cd "$TARGET_DIR" || exit 1
    pwd
  )

  echo "Directory: $DIR_NAME"

  LIB_DIR="$DIR_NAME/lib"
  mkdir -p "$LIB_DIR"

  FILES="bstrap
lib/helpers.sh
lib/01_packages.sh
lib/02_directories.sh
lib/03_permissions.sh
lib/04_services.sh
lib/05_dotfiles.sh
lib/06_fonts.sh"

  for file in $FILES; do
    target="$DIR_NAME/$file"
    if [ "$FORCE" = true ] || [ ! -f "$target" ]; then
      echo "Downloading $file..."
      download_file "${RAW_URL}/${file}" "$target" || {
        echo "Error: failed to download $file" >&2
        exit 1
      }
      chmod +x "$target"
    else
      echo "Skipping $file (already exists)"
    fi
  done

  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
  CONFIG_FILE="$CONFIG_DIR/bstrap.yaml"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Downloading bstrap.yaml..."
    download_file "${RAW_URL}/bstrap.yaml" "$CONFIG_FILE" || {
      echo "Error: failed to download bstrap.yaml" >&2
      exit 1
    }
  else
    echo "Skipping bstrap.yaml (already exists)"
  fi

  if [ "$SELF_DELETE" = true ]; then
    echo "Deleting script: $0"
    rm -- "$0"
  fi
}

main "$@"
