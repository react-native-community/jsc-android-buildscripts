#!/bin/bash -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOTDIR=$(cd "${SCRIPT_DIR}/.." && pwd)

VARIANT="${JSC_NDK_VARIANT:-$1}"
if [[ -z "$VARIANT" ]]; then
  echo "Usage: ${BASH_SOURCE[0]} <variant>" >&2
  echo "       or set JSC_NDK_VARIANT in the environment." >&2
  exit 1
fi

echo "Preparing JS smoke test binary for variant ${VARIANT}"

if [[ -z "$ANDROID_NDK" || ! -d "$ANDROID_NDK" ]]; then
  echo "ANDROID_NDK must point to the NDK installation for variant ${VARIANT}" >&2
  exit 1
fi

export ROOTDIR
export JSC_NDK_VARIANT="$VARIANT"
export JSC_TOOLCHAIN_SUPPRESS_LOG=1
source "${ROOTDIR}/scripts/toolchain.sh"
unset JSC_TOOLCHAIN_SUPPRESS_LOG

DIST_DIR="${JSC_DIST_DIR:-}"
if [[ -z "$DIST_DIR" || ! -d "$DIST_DIR" ]]; then
  echo "Distribution directory for variant ${VARIANT} not found (expected at ${DIST_DIR:-unknown})." >&2
  exit 1
fi

mkdir -p "${DIST_DIR}/smoke-test"

INCLUDE_DIR="${DIST_DIR}/include"
if [[ ! -d "$INCLUDE_DIR" ]]; then
  echo "Missing headers directory at ${INCLUDE_DIR} for variant ${VARIANT}." >&2
  exit 1
fi

JSC_AAR=$(find "${DIST_DIR}" -path "*io/*/jsc-android/*/jsc-android-*.aar" -print -quit)
if [[ -z "$JSC_AAR" ]]; then
  echo "Unable to locate jsc-android AAR inside ${DIST_DIR}." >&2
  exit 1
fi

CPPR_AAR=$(find "${DIST_DIR}" -name "*cppruntime-*.aar" -print -quit)

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

ABIS=("x86_64" "arm64-v8a")

abi_to_triple() {
  case "$1" in
    x86_64)
      echo "x86_64-linux-android"
      ;;
    arm64-v8a)
      echo "aarch64-linux-android"
      ;;
    *)
      echo ""
      ;;
  esac
}

TOOLCHAIN_DIR=$(ls -1 "$ANDROID_NDK/toolchains/llvm/prebuilt" | head -1)
if [[ -z "$TOOLCHAIN_DIR" ]]; then
  echo "Failed to locate LLVM toolchain inside ${ANDROID_NDK}." >&2
  exit 1
fi

API_LEVEL=29

for ABI in "${ABIS[@]}"; do
  TRIPLE=$(abi_to_triple "$ABI")
  if [[ -z "$TRIPLE" ]]; then
    echo "Unknown ABI mapping for ${ABI}" >&2
    exit 1
  fi

  rm -rf "${TMP_DIR}/jsc" "${TMP_DIR}/cppr"

  unzip -qq "$JSC_AAR" "jni/${ABI}/libjsc.so" -d "${TMP_DIR}/jsc"
  JSC_SO="${TMP_DIR}/jsc/jni/${ABI}/libjsc.so"
  if [[ ! -f "$JSC_SO" ]]; then
    echo "Extracted libjsc.so for ABI ${ABI} not found." >&2
    exit 1
  fi

  CPP_SO=""
  if [[ -n "$CPPR_AAR" ]]; then
    unzip -qq "$CPPR_AAR" "jni/${ABI}/libc++_shared.so" -d "${TMP_DIR}/cppr" || true
    CPP_SO="${TMP_DIR}/cppr/jni/${ABI}/libc++_shared.so"
  fi

  CLANG_BIN="${ANDROID_NDK}/toolchains/llvm/prebuilt/${TOOLCHAIN_DIR}/bin/${TRIPLE}${API_LEVEL}-clang++"
  if [[ ! -x "$CLANG_BIN" ]]; then
    echo "Compiler ${CLANG_BIN} not found or not executable." >&2
    exit 1
  fi

  if [[ -z "$CPP_SO" || ! -f "$CPP_SO" ]]; then
    CPP_SO="${ANDROID_NDK}/toolchains/llvm/prebuilt/${TOOLCHAIN_DIR}/sysroot/usr/lib/${TRIPLE}/libc++_shared.so"
    if [[ ! -f "$CPP_SO" ]]; then
      CPP_SO="${ANDROID_NDK}/toolchains/llvm/prebuilt/${TOOLCHAIN_DIR}/sysroot/usr/lib/${TRIPLE}/${API_LEVEL}/libc++_shared.so"
    fi
    if [[ ! -f "$CPP_SO" ]]; then
      echo "Unable to locate libc++_shared.so for ABI ${ABI} (variant ${VARIANT})." >&2
      exit 1
    fi
  fi

  OUT_DIR="${DIST_DIR}/smoke-test/${ABI}"
  mkdir -p "$OUT_DIR"

  ${CLANG_BIN} \
    -std=c++${JSC_TOOLCHAIN_CXX_STANDARD:-23} \
    -Wall -Wextra -Werror \
    -I"${INCLUDE_DIR}" \
    "${ROOTDIR}/tools/android-js-runner/main.cpp" \
    -L"$(dirname "$JSC_SO")" \
    -ljsc \
    -lc++_shared \
    -llog \
    -landroid \
    -o "${OUT_DIR}/js-runner"

  cp "$JSC_SO" "${OUT_DIR}/libjsc.so"
  cp "$JSC_SO" "${OUT_DIR}/libJavaScriptCore.so"
  cp "$CPP_SO" "${OUT_DIR}/libc++_shared.so"
done
