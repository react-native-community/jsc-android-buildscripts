#!/bin/bash -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOTDIR=$(cd "${SCRIPT_DIR}/.." && pwd)

VARIANT="$1"
if [[ -z "$VARIANT" ]]; then
  echo "Usage: ${BASH_SOURCE[0]} <variant-id> [abi]" >&2
  exit 1
fi

REQUESTED_ABI="${2:-arm64-v8a}"
SCRIPT_ARG_COUNT=$#

SCRIPT_CONTENT=""
SCRIPT_FILE_HOST=""

if [[ -n "${JSC_SMOKETEST_SCRIPT_FILE:-}" ]]; then
  SCRIPT_FILE_HOST="$JSC_SMOKETEST_SCRIPT_FILE"
elif [[ -n "${JSC_SMOKETEST_SCRIPT:-}" ]]; then
  SCRIPT_CONTENT="${JSC_SMOKETEST_SCRIPT}"
elif [[ $SCRIPT_ARG_COUNT -ge 3 ]]; then
  SCRIPT_CONTENT="${*:3}"
fi

if [[ "$REQUESTED_ABI" == "all" ]]; then
  ABIS=("arm64-v8a" "x86_64")
else
  ABIS=("$REQUESTED_ABI")
fi

DIST_RELATIVE=$(node /dev/stdin "$ROOTDIR" "$VARIANT" <<'NODE'
const fs = require('fs');
const path = require('path');
const root = process.argv[2];
const variantId = process.argv[3];
const pkg = require(path.join(root, 'package.json'));
const variants = Array.isArray(pkg.config?.ndkVariants) ? pkg.config.ndkVariants : [];
const variant = variants.find((entry) => entry && entry.id === variantId);
if (!variant) {
  console.error(`Unknown NDK variant: ${variantId}`);
  process.exit(1);
}
const dir = variant.distDir || 'dist';
process.stdout.write(dir);
NODE
)

if [[ -z "$DIST_RELATIVE" ]]; then
  echo "Unable to determine dist directory for variant ${VARIANT}" >&2
  exit 1
fi

DIST_DIR="${ROOTDIR}/${DIST_RELATIVE}"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is required to run this test." >&2
  exit 1
fi

for ABI in "${ABIS[@]}"; do
  echo "Running JS smoke test for variant ${VARIANT} (${ABI})" >&2

  ASSET_DIR="${DIST_DIR}/smoke-test/${ABI}"
  if [[ ! -d "$ASSET_DIR" ]]; then
    echo "Smoke-test assets not found at ${ASSET_DIR} for variant ${VARIANT}" >&2
    exit 1
  fi

  DEVICE_DIR="/data/local/tmp/jsc-smoke-${VARIANT}-${ABI}"
  adb shell "rm -rf ${DEVICE_DIR}" >/dev/null
  adb shell "mkdir -p ${DEVICE_DIR}" >/dev/null
  adb push "${ASSET_DIR}/." "${DEVICE_DIR}" >/dev/null
  adb shell "chmod 755 ${DEVICE_DIR}/js-runner" >/dev/null

  DEVICE_SCRIPT_PATH=""
  HOST_TEMP_SCRIPT=""
  if [[ -n "$SCRIPT_FILE_HOST" ]]; then
    if [[ ! -f "$SCRIPT_FILE_HOST" ]]; then
      echo "Script file not found: $SCRIPT_FILE_HOST" >&2
      exit 1
    fi
    DEVICE_SCRIPT_PATH="${DEVICE_DIR}/benchmark.js"
    adb push "$SCRIPT_FILE_HOST" "$DEVICE_SCRIPT_PATH" >/dev/null
  elif [[ -n "$SCRIPT_CONTENT" ]]; then
    HOST_TEMP_SCRIPT=$(mktemp)
    printf "%s\n" "$SCRIPT_CONTENT" > "$HOST_TEMP_SCRIPT"
    DEVICE_SCRIPT_PATH="${DEVICE_DIR}/benchmark.js"
    adb push "$HOST_TEMP_SCRIPT" "$DEVICE_SCRIPT_PATH" >/dev/null
    rm -f "$HOST_TEMP_SCRIPT"
  fi

  RUN_COMMAND="./js-runner"
  if [[ -n "$DEVICE_SCRIPT_PATH" ]]; then
    RUN_COMMAND+=" --file ${DEVICE_SCRIPT_PATH}"
  fi

  set +e
  OUTPUT=$(adb shell "cd ${DEVICE_DIR} && LD_LIBRARY_PATH=${DEVICE_DIR} ${RUN_COMMAND}" 2>&1)
  EXIT_CODE=$?
  set -e

  adb shell "rm -rf ${DEVICE_DIR}" >/dev/null

  echo "$OUTPUT"

  if [[ $EXIT_CODE -ne 0 ]]; then
    exit $EXIT_CODE
  fi

  if [[ -z "$DEVICE_SCRIPT_PATH" ]]; then
    if ! grep -q "PASS" <<<"$OUTPUT"; then
      echo "Smoke test failed for variant ${VARIANT} (${ABI})" >&2
      exit 1
    fi
  fi
done
