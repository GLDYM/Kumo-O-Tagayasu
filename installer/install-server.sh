#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PAKKU_URL="https://github.com/juraj-hrivnak/Pakku/releases/download/v1.3.2/pakku.jar"
FORGE_VERSION="${FORGE_VERSION:-1.20.1-47.4.6}"
FORGE_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"

SERVER_DIR="server"
SERVERPACK_DIR="build/serverpack"

# === Color Prompts ===
YELLOW="\033[33m"; GREEN="\033[32m"; RED="\033[31m"; RESET="\033[0m"

# === Utility Functions ===
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

# === Check Java ===
function check_java() {
  if ! have_cmd java; then
    echo -e "${RED}Didn't detect Java, please install it first (recommended JDK 21 or above).${RESET}"
    exit 1
  fi
  echo -e "${GREEN}Java detected: $(java -version 2>&1 | head -n 1)${RESET}"
}

# === pakku Management ===
function ensure_pakku() {
  if [[ -f "pakku.jar" ]]; then
    echo -e "${GREEN}pakku.jar already exists, skipping download.${RESET}"
  else
    echo -e "${YELLOW}Downloading pakku.jar...${RESET}"
    downloader "$PAKKU_URL" "pakku.jar"
    echo -e "${GREEN}pakku.jar download completed.${RESET}"
  fi
}

# === Build Serverpack ===
function build_serverpack() {
  ensure_unzip
  mkdir -p "$SERVER_DIR"

  shopt -s nullglob
  local zips=("$SERVERPACK_DIR"/*.zip)
  shopt -u nullglob

  if (( ${#zips[@]} == 0 )); then
    echo -e "${YELLOW}${SERVERPACK_DIR}/*.zip Didn't find, using pakku.jar to build serverpack...${RESET}"
    java -jar pakku.jar export
  else
    echo -e "${GREEN}Found existing zip files in ${SERVERPACK_DIR}, skipping pakku build.${RESET}"
  fi

  echo -e "${YELLOW}Extracting serverpack to ./${SERVER_DIR}${RESET}"
  for zipfile in "${zips[@]}"; do
    echo -e "${YELLOW}Extracting $zipfile ...${RESET}"
    do_unzip "$zipfile" "$SERVER_DIR"
  done
  echo -e "${GREEN}serverpack extraction completed.${RESET}"
}

# === Forge Installer Management ===
function ensure_forge_installer() {
  mkdir -p "$SERVER_DIR"
  local local_installer
  local_installer=$(ls forge-*-installer.jar 2>/dev/null | head -n 1 || true)

  if [[ -n "$local_installer" ]]; then
    echo -e "${GREEN}Detected local ${local_installer}, copying to ${SERVER_DIR}${RESET}"
    cp "$local_installer" "${SERVER_DIR}/"
  else
    echo -e "${YELLOW}Downloading Forge installer version ${FORGE_VERSION}...${RESET}"
    local target_installer="${SERVER_DIR}/forge-${FORGE_VERSION}-installer.jar"
    downloader "$FORGE_URL" "$target_installer"
    echo -e "${GREEN}Forge installer download completed: ${target_installer}${RESET}"
  fi
}

# === Install Forge ===
function install_forge() {
  echo -e "${YELLOW}Installing Forge in ./${SERVER_DIR}...${RESET}"
  pushd "$SERVER_DIR" >/dev/null

  local installer
  installer=$(ls forge-*-installer.jar 2>/dev/null | head -n 1 || true)

  if [[ -z "$installer" ]]; then
    echo -e "${RED}Forge installer not found, please check if the download was successful.${RESET}"
    exit 1
  fi

  java -jar "$installer" --installServer >/dev/null 2>&1
  echo -e "${GREEN}Forge installation completed.${RESET}"
  
  echo -e "${YELLOW}Generating eula.txt...${RESET}"
  echo "eula=true" > eula.txt

  echo -e "${YELLOW}Cleaning up invalid files...${RESET}"
  rm -f "$installer" installer.log *.log 2>/dev/null || true
  popd >/dev/null
}

# === Main Process ===
echo -e "${GREEN}==== Kumo-O-Tagayasu Server Build Script ====${RESET}"
check_java
ensure_pakku
build_serverpack
ensure_forge_installer
install_forge
echo -e "${GREEN}Build completed! The server has been generated in ./${SERVER_DIR} directory. You can now delete other files.${RESET}"
