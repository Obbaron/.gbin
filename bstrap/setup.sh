#!/usr/bin/env sh

SELF_DELETE=true
while [ "${1#-}" != "$1" ]; do
  case "$1" in
    -k|--keep) SELF_DELETE=false ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

FILE_NAME="bstrap"

mkdir -p "${1:-$HOME/.local/bin/bstrap}"
DIR_NAME=$(cd "${1:-$HOME/.local/bin/bstrap}" && pwd)
echo "Created directory: $DIR_NAME"

if command -v curl >/dev/null 2>&1; then
  DOWNLOAD="curl -fsL"
  OUTPUT="-o"
elif command -v wget >/dev/null 2>&1; then
  DOWNLOAD="wget -q"
  OUTPUT="-O"
else
  echo "Error: Cannot bootstrap without curl or wget" >&2
  exit 1
fi

touch "$DIR_NAME/$FILE_NAME"
chmod +x "$DIR_NAME/$FILE_NAME"
echo "Created file: $DIR_NAME/$FILE_NAME"

if [ "$SELF_DELETE" = true ]; then
  echo "Deleting script: $0"
  rm -- "$0"
fi
