#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)
export ANDROID_API=21

compile_arch() {
  printf "\n\n\n=================== compiling toolchain for $JSC_ARCH ===================\n\n\n"
  $SCRIPT_DIR/toolchain.sh
  printf "\n\n\n=================== compiling icu for $JSC_ARCH ===================\n\n\n"
  $SCRIPT_DIR/icu.sh
  printf "\n\n\n=================== compiling jsc for $JSC_ARCH ===================n\n\n"
  $SCRIPT_DIR/jsc.sh
}

compile() {
  for arch in arm x86
  do
    export JSC_ARCH=$arch
    export ENABLE_COMPAT=1
    compile_arch
  done

  for arch in arm64 x86_64
  do
    export JSC_ARCH=$arch
    export ENABLE_COMPAT=0
    compile_arch
  done
}

if ${npm_package_config_i18n}
then
  export FLAVOR=intl
  export ENABLE_INTL=1
  compile
else
  export FLAVOR=no-intl
  export ENABLE_INTL=0
  compile
fi
