#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)

compile_arch() {
  echo -e '\033]2;'"compiling icu for $JSC_ARCH $FLAVOR"'\007'
  printf "\n\n\n\t\t=================== compiling icu for $JSC_ARCH $FLAVOR ===================\n\n\n"
  $SCRIPT_DIR/icu.sh

  echo -e '\033]2;'"compiling jsc for $JSC_ARCH $FLAVOR"'\007'
  printf "\n\n\n\t\t=================== compiling jsc for $JSC_ARCH $FLAVOR ===================\n\n\n"
  $SCRIPT_DIR/jsc.sh

  echo "-= Finished compiling for $JSC_ARCH $FLAVOR =-"
}

compile() {
  for arch in arm x86
  do
    export ANDROID_API=$ANDROID_API_FOR_ABI_32
    export JSC_ARCH=$arch
    compile_arch
  done

  for arch in arm64 x86_64
  do
    export ANDROID_API=$ANDROID_API_FOR_ABI_64
    export JSC_ARCH=$arch
    compile_arch
  done
}

export FLAVOR=intl
export ENABLE_INTL=1
compile
