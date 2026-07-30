#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob

# ===== Module: Runtime Configuration =====
SERVER_DIR="${SERVER_DIR:-server}"
CLIENT_DIR="${CLIENT_DIR:-client}"
LOCKFILE_PATH="${LOCKFILE_PATH:-pakku-lock.json}"
USERNAME="${CLIENT_USERNAME:-Dev}"
SERVER_HOST="${SERVER_HOST:-localhost}"
SERVER_PORT="${SERVER_PORT:-25565}"

# ===== Module: Preflight Checks =====
if [[ ! -d "$SERVER_DIR" ]]; then
  echo "Server directory not found: $SERVER_DIR"
  exit 1
fi

if [[ ! -f "$LOCKFILE_PATH" ]]; then
  echo "Lockfile not found: $LOCKFILE_PATH"
  exit 1
fi

if ! command -v portablemc >/dev/null 2>&1; then
  echo "portablemc is not available in PATH"
  exit 1
fi

if [[ -z "${DISPLAY:-}" ]]; then
  echo "DISPLAY is not set. Xvfb is required for client launch."
  exit 1
fi

# ===== Module: Diagnostics Helpers =====
print_server_diagnostics() {
  echo "===== Server Diagnostics ====="

#   if [[ -f "$SERVER_DIR/server.log" ]]; then
#     echo "===== server.log ====="
#     cat "$SERVER_DIR/server.log" || true
#   fi

  if [[ -f "$SERVER_DIR/logs/debug.log" ]]; then
    echo "===== logs/debug.log ====="
    cat "$SERVER_DIR/logs/debug.log" || true
  fi

  if [[ -f "$SERVER_DIR/logs/kubejs/startup.log" ]]; then
    echo "===== logs/kubejs/startup.log ====="
    cat "$SERVER_DIR/logs/kubejs/startup.log" || true
  fi

  if ls "$SERVER_DIR"/crash-reports/*.txt >/dev/null 2>&1; then
    echo "===== crash-reports ====="
    cat "$SERVER_DIR"/crash-reports/*.txt || true
  fi
}

print_client_diagnostics() {
  echo "===== Client Diagnostics ====="

#   if [[ -f "$CLIENT_DIR/client.log" ]]; then
#     echo "===== client.log ====="
#     cat "$CLIENT_DIR/client.log" || true
#   fi

  if [[ -f "$CLIENT_DIR/.minecraft/logs/debug.log" ]]; then
    echo "===== .minecraft/logs/debug.log ====="
    cat "$CLIENT_DIR/.minecraft/logs/debug.log" || true
  fi

  if ls "$CLIENT_DIR"/.minecraft/crash-reports/*.txt >/dev/null 2>&1; then
    echo "===== .minecraft/crash-reports ====="
    cat "$CLIENT_DIR"/.minecraft/crash-reports/*.txt || true
  fi
}

wait_for_log_with_process_check() {
  local log_file="$1"
  local log_pattern="$2"
  local pid="$3"
  local timeout_seconds="$4"
  local process_name="$5"

  local elapsed=0
  while (( elapsed < timeout_seconds )); do
    if [[ -f "$log_file" ]] && grep -q "$log_pattern" "$log_file"; then
      return 0
    fi

    if ! kill -0 "$pid" 2>/dev/null; then
      echo "$process_name exited before reaching the expected state"
      return 1
    fi

    sleep 10
    elapsed=$((elapsed + 10))
  done

  if [[ -f "$log_file" ]] && grep -q "$log_pattern" "$log_file"; then
    return 0
  fi

  echo "Timed out waiting for $process_name to reach the expected state"
  return 1
}

# ===== Module: Client Profile Bootstrap =====
mkdir -p "$CLIENT_DIR/.minecraft"
cat > "$CLIENT_DIR/.minecraft/options.txt" <<EOF
skipMultiplayerWarning:true
onboardAccessibility:false
joinedFirstServer:true
tutorialStep:none
EOF

# ===== Module: Launch Target Resolution =====
launch_info_file="$(mktemp)"
python3 ./.github/scripts/resolve-client-launch-targets.py "$LOCKFILE_PATH" "$launch_info_file"
readarray -t launch_info < "$launch_info_file"
rm -f "$launch_info_file"

if [[ "${#launch_info[@]}" -lt 2 ]]; then
  echo "Unable to resolve Minecraft launch target from lockfile"
  exit 1
fi

MC_VERSION="${launch_info[0]}"
TARGETS=("${launch_info[@]:1}")

echo "Resolved MC version: $MC_VERSION"
echo "Trying launch targets: ${TARGETS[*]}"

# Probe candidate targets with dry-run to pick a compatible entry for current portablemc.
selected_target=""
for target in "${TARGETS[@]}"; do
  echo "Checking launch target: $target"
  dry_log_file="$(mktemp)"
  if portablemc --main-dir "$CLIENT_DIR/.minecraft" start "$target" -u "$USERNAME" --dry > /dev/null 2> "$dry_log_file"; then
    selected_target="$target"
    rm -f "$dry_log_file"
    break
  else
    echo "Target failed: $target"
    sed -n '1,8p' "$dry_log_file" || true
    rm -f "$dry_log_file"
  fi
done

if [[ -z "$selected_target" ]]; then
  echo "Failed to resolve a valid portablemc launch target"
  exit 1
fi

echo "Selected launch target: $selected_target"

# ===== Module: Server Runtime Preparation =====
if [[ -f "$SERVER_DIR/server.properties" ]]; then
  if grep -q '^online-mode=' "$SERVER_DIR/server.properties"; then
    sed -i 's/^online-mode=.*/online-mode=false/' "$SERVER_DIR/server.properties"
  else
    echo 'online-mode=false' >> "$SERVER_DIR/server.properties"
  fi
else
  echo 'online-mode=false' > "$SERVER_DIR/server.properties"
fi

# ===== Module: Server Launch =====
pushd "$SERVER_DIR" >/dev/null
chmod +x run.sh

./run.sh > server.log 2>&1 &
SERVER_PID=$!

echo "Started server with PID $SERVER_PID"

# ===== Module: Process Cleanup =====
cleanup() {
  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ -n "${CLIENT_PID:-}" ]] && kill -0 "$CLIENT_PID" 2>/dev/null; then
    kill "$CLIENT_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# ===== Module: Server Startup Verification =====
# If a server doesn't start within 5 minutes, we assumed it failed to start and exit with error.
# For Github Actions' powerful machines, over 5 minutes is not acceptable.
if ! wait_for_log_with_process_check "server.log" 'Done ([0-9.]\+s)! For help, type "help"' "$SERVER_PID" 300 "Server"; then
  echo "Server did not start successfully"
  popd >/dev/null
  print_server_diagnostics
  exit 1
fi

echo "Server started, launching client"
popd >/dev/null

# ===== Module: Client Launch =====
portablemc_cmd=(
  portablemc
  --main-dir "$CLIENT_DIR/.minecraft"
  start "$selected_target"
  -u "$USERNAME"
  --jvm-arg=-Xmx8G,-Xms8G
  --join-server "$SERVER_HOST"
  --join-server-port "$SERVER_PORT"
)

"${portablemc_cmd[@]}" > "$CLIENT_DIR/client.log" 2>&1 &

CLIENT_PID=$!

echo "Started client with PID $CLIENT_PID"

# ===== Module: Client Join Verification =====
if ! wait_for_log_with_process_check "$SERVER_DIR/server.log" "$USERNAME joined the game" "$CLIENT_PID" 360 "Client"; then
  echo "===== Client did not join server in time ====="
  print_server_diagnostics
  print_client_diagnostics
  exit 1
fi

echo "===== Client joined server successfully ====="
echo "Waiting for 5 minutes to monitor stability after client join..."

# ===== Module: Stability Monitoring =====
for i in {1..30}; do
  sleep 10

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "===== Server crashed after client joined ====="
    print_server_diagnostics
    print_client_diagnostics
    exit 1
  fi

  if ! kill -0 "$CLIENT_PID" 2>/dev/null; then
    echo "===== Client crashed after joining ====="
    print_server_diagnostics
    print_client_diagnostics
    exit 1
  fi
done

# ===== Module: Success Summary =====
echo "===== Client connection test passed ====="

print_server_diagnostics
print_client_diagnostics

echo "===== Client connection test passed ====="
exit 0
