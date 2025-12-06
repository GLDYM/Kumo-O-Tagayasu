#!/usr/bin/env bash
set -euo pipefail

# === 配置区 ===
PAKKU_URL="https://github.com/juraj-hrivnak/Pakku/releases/download/v1.3.2/pakku.jar"
FORGE_VERSION="${FORGE_VERSION:-1.20.1-47.4.6}"
FORGE_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"

SERVER_DIR="server"
SERVERPACK_DIR="build/serverpack"

# === 颜色提示 ===
YELLOW="\033[33m"; GREEN="\033[32m"; RED="\033[31m"; RESET="\033[0m"

# === 工具函数 ===
function have_cmd() { command -v "$1" >/dev/null 2>&1; }

function downloader() {
  if have_cmd curl; then
    curl -L --retry 3 --fail -o "$2" "$1" >/dev/null 2>&1s
  elif have_cmd wget; then
    wget -O "$2" "$1" >/dev/null 2>&1
  else
    echo -e "${RED}未检测到 curl 或 wget，请安装其中之一后重试。${RESET}"
    exit 1
  fi
}

function ensure_unzip() {
  if ! have_cmd unzip && ! have_cmd bsdtar; then
    echo -e "${RED}未检测到 unzip 或 bsdtar，请安装解压工具。${RESET}"
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

# === 检查 Java ===
function check_java() {
  if ! have_cmd java; then
    echo -e "${RED}未检测到 Java，请先安装（推荐 JDK 17 或以上）。${RESET}"
    exit 1
  fi
  echo -e "${GREEN}Java 已检测到：$(java -version 2>&1 | head -n 1)${RESET}"
}

# === pakku 管理 ===
function ensure_pakku() {
  if [[ -f "pakku.jar" ]]; then
    echo -e "${GREEN}已存在 pakku.jar，跳过下载。${RESET}"
  else
    echo -e "${YELLOW}下载 pakku.jar...${RESET}"
    downloader "$PAKKU_URL" "pakku.jar"
    echo -e "${GREEN}pakku.jar 下载完成。${RESET}"
  fi
}

# === 构建服务端 ===
function build_serverpack() {
  ensure_unzip
  mkdir -p "$SERVER_DIR"

  local serverpack_zip
  serverpack_zip=$(ls "${SERVERPACK_DIR}"/*.zip 2>/dev/null | head -n 1 || true)
  
  if [[ -n "$serverpack_zip" ]]; then
    echo -e "${GREEN}检测到已有 serverpack 文件 ${serverpack_zip}，跳过构建。${RESET}"s
    return
  else
    echo -e "${YELLOW}使用 pakku.jar 构建服务端...${RESET}"
    java -jar pakku.jar export
    echo -e "${GREEN}服务端构建完成。${RESET}"
  fi

  echo -e "${YELLOW}解压 serverpack 到 ./${SERVER_DIR}${RESET}"
  for zipfile in "${zips[@]}"; do
    echo "解压 $zipfile ..."
    do_unzip "$zipfile" "$SERVER_DIR"
  done
  echo -e "${GREEN}serverpack 解压完成。${RESET}"
}

# === Forge 安装器管理 ===
function ensure_forge_installer() {
  mkdir -p "$SERVER_DIR"
  local local_installer
  local_installer=$(ls forge-*-installer.jar 2>/dev/null | head -n 1 || true)

  if [[ -n "$local_installer" ]]; then
    echo -e "${GREEN}检测到本地 ${local_installer}，复制到 ${SERVER_DIR}${RESET}"
    cp "$local_installer" "${SERVER_DIR}/"
  else
    echo -e "${YELLOW}下载 Forge 安装器版本 ${FORGE_VERSION}...${RESET}"
    local target_installer="${SERVER_DIR}/forge-${FORGE_VERSION}-installer.jar"
    downloader "$FORGE_URL" "$target_installer"
    echo -e "${GREEN}Forge 安装器下载完成：${target_installer}${RESET}"
  fi
}

# === 安装 Forge ===
function install_forge() {
  echo -e "${YELLOW}在 ./${SERVER_DIR} 下安装 Forge...${RESET}"
  pushd "$SERVER_DIR" >/dev/null

  local installer
  installer=$(ls forge-*-installer.jar 2>/dev/null | head -n 1 || true)

  if [[ -z "$installer" ]]; then
    echo -e "${RED}未找到 forge 安装器，请检查下载是否成功。${RESET}"
    exit 1
  fi

  java -jar "$installer" --installServer >/dev/null 2>&1
  echo -e "${GREEN}Forge 安装完成。${RESET}"
  
  echo -e "${YELLOW}生成 eula.txt...${RESET}"
  echo "eula=true" > eula.txt

  echo -e "${YELLOW}清理无效文件...${RESET}"
  rm -f "$installer" installer.log *.log 2>/dev/null || true
  popd >/dev/null
}

# === 主流程 ===
echo -e "${GREEN}==== Kumo-O-Tagayasu 服务端自动构建脚本 ====${RESET}"
check_java
ensure_pakku
build_serverpack
ensure_forge_installer
install_forge
echo -e "${GREEN}构建完成！服务端已生成在 ./${SERVER_DIR} 目录下。你现在可以删除其他文件了。${RESET}"
echo -e "${YELLOW}提示：你可以通过设置环境变量 FORGE_VERSION 来指定 Forge 版本，例如：${RESET}"
echo -e "${YELLOW}  FORGE_VERSION=1.20.1-47.2.0 ./install.sh${RESET}"
