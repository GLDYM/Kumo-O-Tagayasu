#!/usr/bin/env bash

# prepare-client-mods.sh
# Prepare client by merging overrides and downloading mods 
# specified in pakku-lock.json.
# If Portable MC adds their support of Curseforge modpack format,
# this file is no longer needed.

set -euo pipefail

LOCKFILE_PATH="${1:-pakku-lock.json}"
PAKKU_JSON_PATH="${2:-pakku.json}"
CLIENT_DIR="${3:-client}"
PAKKU_DIR="${4:-.pakku}"

if [[ ! -f "$LOCKFILE_PATH" ]]; then
  echo "Lockfile not found: $LOCKFILE_PATH"
  exit 1
fi

if [[ ! -d "$PAKKU_DIR" ]]; then
  echo "Pakku directory not found: $PAKKU_DIR"
  exit 1
fi

if [[ ! -f "$PAKKU_JSON_PATH" ]]; then
  echo "Pakku config not found: $PAKKU_JSON_PATH"
  exit 1
fi

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

download_file() {
  local url="$1"
  local out="$2"
  if have_cmd curl; then
    curl -L --retry 3 --retry-all-errors --fail -o "$out" "$url"
  else
    wget -O "$out" "$url"
  fi
}

rm -rf "$CLIENT_DIR"
mkdir -p "$CLIENT_DIR/.minecraft/mods"

echo "Merging overrides into $CLIENT_DIR/.minecraft"
if [[ -d "$PAKKU_DIR/overrides" ]]; then
  cp -a "$PAKKU_DIR/overrides/." "$CLIENT_DIR/.minecraft/"
fi
if [[ -d "$PAKKU_DIR/client-overrides" ]]; then
  cp -a "$PAKKU_DIR/client-overrides/." "$CLIENT_DIR/.minecraft/"
fi

tmp_list="$(mktemp)"

python3 ./.github/scripts/resolve-client-mod-downloads.py "$LOCKFILE_PATH" "$PAKKU_JSON_PATH" "$tmp_list"

download_count=0
while IFS=$'\t' read -r url file_name sha1; do
  [[ -z "${url:-}" ]] && continue
  target="$CLIENT_DIR/.minecraft/mods/$file_name"

  echo "Downloading $file_name"
  download_file "$url" "$target"

  if [[ -n "${sha1:-}" ]] && have_cmd sha1sum; then
    actual_sha1="$(sha1sum "$target" | awk '{print $1}')"
    if [[ "$actual_sha1" != "$sha1" ]]; then
      echo "SHA1 mismatch for $file_name"
      echo "Expected: $sha1"
      echo "Actual:   $actual_sha1"
      exit 1
    fi
  fi

  download_count=$((download_count + 1))
done < "$tmp_list"

rm -f "$tmp_list"
echo "Prepared client .minecraft with $download_count downloaded mods"
