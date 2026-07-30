#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
CONFIG_PATH=""
PAKKU_URL=""
LOCKFILE_PATH=""
SERVER_DIR=""
SERVERPACK_DIR=""
FORGE_INSTALLER_URL_TEMPLATE=""
NEOFORGE_INSTALLER_URL_TEMPLATE=""
FABRIC_INSTALLER_VERSION=""
FABRIC_INSTALLER_URL_TEMPLATE=""
LOADER_NAME=""
LOADER_VERSION=""
MC_VERSION=""
LOADER_INSTALLER_URL=""
INSTALLER_FILE_GLOB=""
INSTALLER_TARGET_FILE=""

# ==== Color Prompts ====
YELLOW="\033[33m"; GREEN="\033[32m"; RED="\033[31m"; RESET="\033[0m"

# ==== Utility Functions ====
function have_cmd() { command -v "$1" >/dev/null 2>&1; }

function downloader() {
  if have_cmd curl; then
    curl -L --retry 3 --fail -o "$2" "$1" >/dev/null 2>&1
  elif have_cmd wget; then
    wget -O "$2" "$1" >/dev/null 2>&1
  else
    echo -e "${RED}Didn't detect curl or wget, please install one of them.${RESET}"
    exit 1
  fi
}

function ensure_unzip() {
  if ! have_cmd unzip && ! have_cmd bsdtar; then
    echo -e "${RED}Didn't detect unzip or bsdtar, please install one of them.${RESET}"
    exit 1
  fi
}

function do_unzip() {
  local zip="$1" dest="$2"
  if have_cmd unzip; then
    unzip -o "$zip" -d "$dest" >/dev/null 2>&1
  else
    bsdtar -xf "$zip" -C "$dest" >/dev/null 2>&1
  fi
}

# ==== Configuration Loading ====
function resolve_config_path() {
  if [[ -f "install-config.properties" ]]; then
    CONFIG_PATH="install-config.properties"
  elif [[ -f "installer/install-config.properties" ]]; then
    CONFIG_PATH="installer/install-config.properties"
  else
    echo -e "${RED}install-config.properties not found in current directory or installer/ directory.${RESET}"
    exit 1
  fi
}

function read_config_value() {
  local key="$1"
  local value
  value="$(sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$CONFIG_PATH" | head -n 1 | tr -d '\r')"

  echo "$value"
}

function load_config() {
  resolve_config_path

  PAKKU_URL="$(read_config_value "pakku_url")"
  LOCKFILE_PATH="$(read_config_value "lockfile_path")"
  SERVER_DIR="$(read_config_value "server_dir")"
  SERVERPACK_DIR="$(read_config_value "serverpack_dir")"
  FORGE_INSTALLER_URL_TEMPLATE="$(read_config_value "forge_installer_url_template")"
  NEOFORGE_INSTALLER_URL_TEMPLATE="$(read_config_value "neoforge_installer_url_template")"
  FABRIC_INSTALLER_VERSION="$(read_config_value "fabric_installer_version")"
  FABRIC_INSTALLER_URL_TEMPLATE="$(read_config_value "fabric_installer_url_template")"

  if [[ -z "$PAKKU_URL" || -z "$LOCKFILE_PATH" || -z "$SERVER_DIR" || -z "$SERVERPACK_DIR" || -z "$FORGE_INSTALLER_URL_TEMPLATE" || -z "$NEOFORGE_INSTALLER_URL_TEMPLATE" || -z "$FABRIC_INSTALLER_VERSION" || -z "$FABRIC_INSTALLER_URL_TEMPLATE" ]]; then
    echo -e "${RED}${CONFIG_PATH} is missing required fields.${RESET}"
    exit 1
  fi
}

# ==== Resolve Loader Info from Lockfile ====
function resolve_loader_from_lockfile() {
  if [[ ! -f "$LOCKFILE_PATH" ]]; then
    echo -e "${RED}pakku-lock.json not found at ${LOCKFILE_PATH}.${RESET}"
    exit 1
  fi

  local lock_json
  lock_json="$(tr -d '\r\n' < "$LOCKFILE_PATH")"

  MC_VERSION="$(echo "$lock_json" | sed -n 's/.*"mc_versions"[[:space:]]*:[[:space:]]*\[[[:space:]]*"\([^"]*\)".*/\1/p')"
  if [[ -z "$MC_VERSION" ]]; then
    echo -e "${RED}Failed to parse mc_versions from pakku-lock.json.${RESET}"
    exit 1
  fi

  if echo "$lock_json" | grep -q '"neoforge"[[:space:]]*:'; then
    LOADER_NAME="neoforge"
    LOADER_VERSION="$(echo "$lock_json" | sed -n 's/.*"neoforge"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    LOADER_INSTALLER_URL="${NEOFORGE_INSTALLER_URL_TEMPLATE//\{loader_version\}/$LOADER_VERSION}"
    INSTALLER_FILE_GLOB="neoforge-*-installer.jar"
    INSTALLER_TARGET_FILE="${LOADER_NAME}-${LOADER_VERSION}-installer.jar"
  elif echo "$lock_json" | grep -q '"forge"[[:space:]]*:'; then
    LOADER_NAME="forge"
    LOADER_VERSION="$(echo "$lock_json" | sed -n 's/.*"forge"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    LOADER_INSTALLER_URL="${FORGE_INSTALLER_URL_TEMPLATE//\{mc_version\}/$MC_VERSION}"
    LOADER_INSTALLER_URL="${LOADER_INSTALLER_URL//\{loader_version\}/$LOADER_VERSION}"
    INSTALLER_FILE_GLOB="forge-*-installer.jar"
    INSTALLER_TARGET_FILE="${LOADER_NAME}-${LOADER_VERSION}-installer.jar"
  elif echo "$lock_json" | grep -q '"fabric"[[:space:]]*:'; then
    LOADER_NAME="fabric"
    LOADER_VERSION="$(echo "$lock_json" | sed -n 's/.*"fabric"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    LOADER_INSTALLER_URL="${FABRIC_INSTALLER_URL_TEMPLATE//\{installer_version\}/$FABRIC_INSTALLER_VERSION}"
    INSTALLER_FILE_GLOB="fabric-installer-*.jar"
    INSTALLER_TARGET_FILE="fabric-installer-${FABRIC_INSTALLER_VERSION}.jar"
  else
    echo -e "${RED}No supported loader found in pakku-lock.json. Supported loaders: forge, neoforge, fabric.${RESET}"
    exit 1
  fi

  if [[ -z "$LOADER_VERSION" || -z "$LOADER_INSTALLER_URL" || -z "$INSTALLER_FILE_GLOB" || -z "$INSTALLER_TARGET_FILE" ]]; then
    echo -e "${RED}Failed to parse loader version from pakku-lock.json.${RESET}"
    exit 1
  fi

  echo -e "${GREEN}Detected loader: ${LOADER_NAME} ${LOADER_VERSION} (MC ${MC_VERSION})${RESET}"
}

# ==== Check Java ====
function check_java() {
  if ! have_cmd java; then
    echo -e "${RED}Didn't detect Java, please install it first (recommended JDK 21 or above).${RESET}"
    exit 1
  fi
  echo -e "${GREEN}Java detected: $(java -version 2>&1 | head -n 1)${RESET}"
}

# ==== Pakku Management ====
function ensure_pakku() {
  if [[ -f "pakku.jar" ]]; then
    echo -e "${GREEN}pakku.jar already exists, skipping download.${RESET}"
  else
    echo -e "${YELLOW}Downloading pakku.jar...${RESET}"
    downloader "$PAKKU_URL" "pakku.jar"
    echo -e "${GREEN}pakku.jar download completed.${RESET}"
  fi
}

# ==== Build Serverpack ====
function build_serverpack() {
  ensure_unzip
  mkdir -p "$SERVER_DIR"

  shopt -s nullglob

  echo -e "${YELLOW}Using pakku.jar to build serverpack...${RESET}"
  java -jar pakku.jar export

  local zips=("$SERVERPACK_DIR"/*.zip)
  echo -e "${YELLOW}Extracting serverpack to ./${SERVER_DIR}${RESET}"
  sleep 30
  for zipfile in "${zips[@]}"; do
    echo -e "${YELLOW}Extracting $zipfile ...${RESET}"
    do_unzip "$zipfile" "$SERVER_DIR"
  done
  echo -e "${GREEN}serverpack extraction completed.${RESET}"
  shopt -u nullglob
}

# ==== Loader Installer Management ====
function ensure_loader_installer() {
  mkdir -p "$SERVER_DIR"
  local local_installer
  local_installer=$(compgen -G "$INSTALLER_FILE_GLOB" | head -n 1 || true)

  if [[ -n "$local_installer" ]]; then
    echo -e "${GREEN}Detected local ${local_installer}, copying to ${SERVER_DIR}${RESET}"
    cp "$local_installer" "${SERVER_DIR}/"
  else
    echo -e "${YELLOW}Downloading ${LOADER_NAME} installer version ${LOADER_VERSION}...${RESET}"
    local target_installer="${SERVER_DIR}/${INSTALLER_TARGET_FILE}"
    downloader "$LOADER_INSTALLER_URL" "$target_installer"
    echo -e "${GREEN}${LOADER_NAME} installer download completed: ${target_installer}${RESET}"
  fi
}

# ==== Install Loader ====
function install_loader() {
  echo -e "${YELLOW}Installing ${LOADER_NAME} in ./${SERVER_DIR}...${RESET}"
  pushd "$SERVER_DIR" >/dev/null

  local installer
  installer=$(compgen -G "$INSTALLER_FILE_GLOB" | head -n 1 || true)

  if [[ -z "$installer" ]]; then
    echo -e "${RED}${LOADER_NAME} installer not found, please check if the download was successful.${RESET}"
    exit 1
  fi

  if [[ "$LOADER_NAME" == "fabric" ]]; then
    java -jar "$installer" server -mcversion "$MC_VERSION" -loader "$LOADER_VERSION" -downloadMinecraft >/dev/null 2>&1
  else
    java -jar "$installer" --installServer >/dev/null 2>&1
  fi
  echo -e "${GREEN}${LOADER_NAME} installation completed.${RESET}"
  
  echo -e "${YELLOW}Generating eula.txt...${RESET}"
  echo "eula=true" > eula.txt

  echo -e "${YELLOW}Cleaning up invalid files...${RESET}"
  rm -f "$installer" installer.log *.log 2>/dev/null || true
  popd >/dev/null
}

# ==== Main Process ====
echo -e "${GREEN}==== Pakku Modpack Template Server Build Script ====${RESET}"
load_config
resolve_loader_from_lockfile
check_java
ensure_pakku
build_serverpack
ensure_loader_installer
install_loader
echo -e "${GREEN}Build completed! The server has been generated in ./${SERVER_DIR} directory. You can now delete other files.${RESET}"
