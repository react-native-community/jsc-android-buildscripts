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
    export ANDROID_API=21
    export ENABLE_COMPAT=1
    compile_arch
  done

  if ${npm_package_config_x64}
  then
    for arch in arm64 x86_64
    do
      export JSC_ARCH=$arch
      export ANDROID_API=21
      export ENABLE_COMPAT=0
      compile_arch
    done
  fi
}

export FLAVOR=no-intl
export ENABLE_INTL=0
compile

if ${npm_package_config_i18n}
then
  export FLAVOR=intl
  export ENABLE_INTL=1
  compile
fi
