#!/usr/bin/env bash

# package-server.sh
# Build full server-pack zip and package zip for release.

set -euo pipefail
shopt -s dotglob

# ==== Configuration ====
SERVER_ZIP_NAME="${1:-}"
FULL_SERVER_ZIP_NAME="${2:-}"

if [[ -z "$SERVER_ZIP_NAME" || -z "$FULL_SERVER_ZIP_NAME" ]]; then
  echo "Usage: $0 <server-zip-name> <full-server-zip-name>"
  exit 1
fi

if [[ ! -f "pakku-lock.json" ]]; then
  echo "pakku-lock.json not found"
  exit 1
fi

INSTALL_CONFIG_PATH=""
if [[ -f "installer/install-config.properties" ]]; then
  INSTALL_CONFIG_PATH="installer/install-config.properties"
else
  echo "installer/install-config.properties not found"
  exit 1
fi

# ==== Build Full Server-pack ====
chmod +x installer/install-server.sh
./installer/install-server.sh

# Package full server zip
zip -r "./${FULL_SERVER_ZIP_NAME}" ./server/*

# ==== Build Lightweight Server-pack ====
cp pakku.json installer/
cp pakku-lock.json installer/
cp pakku.jar installer/
cp -r .pakku/ installer/
rm -rf installer/.pakku/client-overrides/*

# Resolve loader installer
loader_name=""
loader_version=""
installer_file_name=""
installer_url=""

while IFS='=' read -r key value; do
  case "$key" in
    mc_version) mc_version="$value" ;;
    loader_name) loader_name="$value" ;;
    loader_version) loader_version="$value" ;;
    installer_file_name) installer_file_name="$value" ;;
    installer_url) installer_url="$value" ;;
  esac
done < <(python3 ./.github/scripts/resolve-loader-installer-meta.py pakku-lock.json "$INSTALL_CONFIG_PATH")

if [[ -z "$loader_name" || -z "$loader_version" ]]; then
  echo "Unsupported loader in pakku-lock.json"
  exit 1
fi

echo "Detected loader for installer package: ${loader_name} ${loader_version}"
if [[ -n "$installer_url" ]]; then
  wget "$installer_url" -O "$installer_file_name"
  cp "$installer_file_name" installer/
fi

# Package server zip
zip -r "./${SERVER_ZIP_NAME}" ./installer
