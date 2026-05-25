#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="${PYTHON:-python3}"
BUILD_DIR="$ROOT_DIR/build"
E2E_DIR="$BUILD_DIR/e2e"
DEPS_DIR="$E2E_DIR/deps"
PYCACHE_DIR="$E2E_DIR/pycache"
PYTEST_CACHE_DIR="$E2E_DIR/pytest-cache"
TMP_WORK_DIR="$E2E_DIR/tmp"
SERVER_DIR="$E2E_DIR/server"
CONFIG_PATH="$E2E_DIR/openevent-server.yaml"
LOG_PATH="$E2E_DIR/openevent-server.log"

SERVER_BIN="${OPENEVENT_SERVER_BIN:-}"
GRPC_ADDR="${OPENEVENT_E2E_GRPC_ADDR:-127.0.0.1:19527}"
ADMIN_ADDR="${OPENEVENT_E2E_ADMIN_ADDR:-127.0.0.1:19528}"

rm -rf "$DEPS_DIR" "$PYCACHE_DIR" "$PYTEST_CACHE_DIR" "$TMP_WORK_DIR" "$SERVER_DIR"
mkdir -p "$DEPS_DIR" "$PYCACHE_DIR" "$PYTEST_CACHE_DIR" "$TMP_WORK_DIR" "$SERVER_DIR"

if [ -z "$SERVER_BIN" ] || [ ! -x "$SERVER_BIN" ]; then
  printf 'Set OPENEVENT_SERVER_BIN to an executable openevent_server binary before running e2e tests.\n' >&2
  printf 'Current value: %s\n' "${SERVER_BIN:-<empty>}" >&2
  exit 1
fi

cat > "$CONFIG_PATH" <<YAML
grpc:
  listen_addr: "$GRPC_ADDR"

admin:
  listen_addr: "$ADMIN_ADDR"

storage:
  metadata_path: "$SERVER_DIR/meta"

store:
  rocksdb:
    path: "$SERVER_DIR/messages"

limits:
  max_payload_bytes: 16777216

log:
  level: "info"
YAML

export PYTHONPYCACHEPREFIX="$PYCACHE_DIR"
export PYTEST_ADDOPTS="${PYTEST_ADDOPTS:-} -o cache_dir=$PYTEST_CACHE_DIR"
export PIP_NO_CACHE_DIR=1
export PIP_DISABLE_PIP_VERSION_CHECK=1
export TMPDIR="$TMP_WORK_DIR"
export OPENEVENT_E2E=1
export OPENEVENT_E2E_TARGET="$GRPC_ADDR"
export OPENEVENT_E2E_ADMIN_TARGET="$ADMIN_ADDR"

cd "$ROOT_DIR"
./generate_python_proto.sh "$ROOT_DIR"

"$PYTHON_BIN" -m pip install -q --upgrade --target "$DEPS_DIR" ".[test]"
export PYTHONPATH="$ROOT_DIR/src:$DEPS_DIR${PYTHONPATH:+:$PYTHONPATH}"

"$SERVER_BIN" "$CONFIG_PATH" >"$LOG_PATH" 2>&1 &
SERVER_PID=$!

cleanup() {
  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

"$PYTHON_BIN" - <<'PY'
import os
import sys
import time

import grpc

from openevent.sdk import AdminClient

target = os.environ["OPENEVENT_E2E_ADMIN_TARGET"]
deadline = time.time() + 10
last_error = None
while time.time() < deadline:
    try:
        AdminClient(target).list_tokens()
        break
    except grpc.RpcError as exc:
        last_error = exc
        time.sleep(0.1)
else:
    print(f"OpenEvent admin endpoint did not become ready: {last_error}", file=sys.stderr)
    sys.exit(1)
PY

"$PYTHON_BIN" -m pytest tests/test_e2e.py "$@"
