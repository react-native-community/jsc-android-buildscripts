#!/bin/bash

for arch in arm arm64 x86 x86_64
do
  JSC_ARCH=$arch ./toolchain.sh
  JSC_ARCH=$arch ./icu.sh
  JSC_ARCH=$arch ./jsc.sh
done
