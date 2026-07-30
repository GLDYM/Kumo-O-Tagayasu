#!/usr/bin/env bash
set -euo pipefail

cd server
chmod +x run.sh

./run.sh > server.log 2>&1 &
SERVER_PID=$!

echo "Test Server started with PID $SERVER_PID"

# If a server doesn't start within 5 minutes, we assumed it failed to start and exit with error.
# For Github Actions' powerful machines, over 5 minutes is not acceptable.
for i in {1..30}; do
  if grep -q 'Done ([0-9.]\+s)! For help, type "help"' server.log; then
    echo "Server started successfully, running for additional 5 minutes to check stability."
    sleep 300
    if ! kill -0 $SERVER_PID 2>/dev/null; then
      echo "Server process crashed"
      break
    fi
    echo "Server started successfully"
    echo "Show log:"
    cat logs/latest.log
    exit 0
  fi

  if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "Server process crashed"
    break
  fi

  sleep 10
done

echo "Server did not start successfully within timeout or crashed"
echo "Show log:"

if [[ -f logs/kubejs/startup.log ]]; then
  cat logs/kubejs/startup.log
else
  echo "logs/kubejs/startup.log not found"
fi

if [[ -f logs/latest.log ]]; then
  cat logs/latest.log
else
  echo "logs/latest.log not found"
fi

if ls crash-reports/*.txt 1> /dev/null 2>&1; then
  echo "Crash reports found:"
  cat crash-reports/*.txt
else
  echo "No crash reports found."
fi

exit 1
