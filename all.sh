#!/bin/bash -e

compile_arch() {
  echo "=== compiling toolchain ==="
  ./toolchain.sh
  echo "=== compiling icu ==="
  ./icu.sh
  echo "=== compiling jsc ==="
  ./jsc.sh
}

compile() {
  for arch in arm x86
  do
    export JSC_ARCH=$arch
    export ANDROID_API=15
    export ENABLE_COMPAT=1
    compile_arch
  done

  for arch in arm64 x86_64
  do
    export JSC_ARCH=$arch
    export ANDROID_API=21
    export ENABLE_COMPAT=0
    compile_arch
  done
}

export FLAVOR=no-intl
export ENABLE_INTL=0
compile


export FLAVOR=intl
export ENABLE_INTL=1
compile
