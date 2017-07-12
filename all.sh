#!/bin/bash

compile() {
  for arch in arm arm64 x86 x86_64
  do
    export JSC_ARCH=$arch
    ./toolchain.sh
    ./icu.sh
    ./jsc.sh
  done
}

export FLAVOR=no-intl
export ENABLE_INTL=0
compile


export FLAVOR=intl
export ENABLE_INTL=1
compile