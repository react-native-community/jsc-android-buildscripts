#!/bin/bash -e

export ANDROID_API_FOR_ABI_32=29
export ANDROID_API_FOR_ABI_64=29
export ANDROID_TARGET_API=35
export ROOTDIR=$PWD

# Default toolchain locations when not provided.
DEFAULT_ANDROID_HOME="$HOME/Library/Android/sdk"
if [[ -z "$ANDROID_HOME" || ! -d "$ANDROID_HOME" ]]; then
  export ANDROID_HOME="$DEFAULT_ANDROID_HOME"
fi

DEFAULT_ANDROID_NDK="$ANDROID_HOME/ndk/28.2.13676358"
if [[ -z "$ANDROID_NDK" || ! -d "$ANDROID_NDK" ]]; then
  export ANDROID_NDK="$DEFAULT_ANDROID_NDK"
fi

export JSC_TOOLCHAIN_SUPPRESS_LOG=1
source $ROOTDIR/scripts/toolchain.sh
unset JSC_TOOLCHAIN_SUPPRESS_LOG

if [[ -z "$JSC_NDK_VARIANT" && -n "$JSC_TOOLCHAIN_VARIANT" ]]; then
  export JSC_NDK_VARIANT="$JSC_TOOLCHAIN_VARIANT"
fi

if [[ -z "$JAVA_HOME" || ! -x "$JAVA_HOME/bin/java" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      HOMEBREW_JAVA_ROOT="$(brew --prefix openjdk@17 2>/dev/null)/libexec/openjdk.jdk/Contents/Home"
      if [[ -x "$HOMEBREW_JAVA_ROOT/bin/java" ]]; then
        export JAVA_HOME="$HOMEBREW_JAVA_ROOT"
      fi
    fi
  fi
fi

if [[ -n "$JAVA_HOME" && -x "$JAVA_HOME/bin/java" ]]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi

source $ROOTDIR/scripts/env.sh
source $ROOTDIR/scripts/info.sh
export JSC_VERSION=${npm_package_version}
export BUILD_TYPE=Release
# export BUILD_TYPE=Debug

STRIPPED_DIST_DIR=${JSC_DIST_DIR:-${ROOTDIR}/dist-ndk28}
UNSTRIPPED_DIST_DIR=${JSC_DIST_UNSTRIPPED_DIR:-${ROOTDIR}/dist-ndk28.unstripped}

printf "Building with Android NDK variant: %s\n" "${JSC_TOOLCHAIN_VARIANT}"
if [[ -n "$JSC_TOOLCHAIN_NDK_REVISION" ]]; then
  printf "Detected Android NDK revision: %s\n" "${JSC_TOOLCHAIN_NDK_REVISION}"
fi
printf "Using distribution directories:\n"
printf "  stripped   : %s\n" "$STRIPPED_DIST_DIR"
printf "  unstripped : %s\n" "$UNSTRIPPED_DIST_DIR"

SCRIPT_DIR=$(cd `dirname $0`; pwd)

patchAndMakeICU() {
  printf "\n\n\t\t===================== patch and make icu into target/icu/host =====================\n\n"
  ICU_VERSION_MAJOR="$(awk '/ICU_VERSION_MAJOR_NUM/ {print $3}' $TARGETDIR/icu/source/common/unicode/uvernum.h)"
  printf "ICU version: ${ICU_VERSION_MAJOR}\n"
  $SCRIPT_DIR/patch.sh icu
  rm -rf $TARGETDIR/icu/host
  mkdir -p $TARGETDIR/icu/host
  cd $TARGETDIR/icu/host

  local HAS_CLANG=0
  if command -v clang >/dev/null 2>&1 && command -v clang++ >/dev/null 2>&1; then
    HAS_CLANG=1
  fi

  if [[ "$BUILD_TYPE" = "Release" ]]
  then
    local opt_flags="-O2"
    local lto_flag=""
    if [[ $HAS_CLANG -eq 1 ]]; then
      lto_flag="$JSC_TOOLCHAIN_LTO_FLAG"
    elif [[ -n "$JSC_TOOLCHAIN_LTO_FLAG" ]]; then
      lto_flag="-flto"
    fi
    if [[ -n "$lto_flag" ]]; then
      opt_flags="$opt_flags $lto_flag"
    fi
    if [[ $HAS_CLANG -eq 1 && -n "$JSC_TOOLCHAIN_RELEASE_CFLAGS" ]]; then
      opt_flags="$opt_flags $JSC_TOOLCHAIN_RELEASE_CFLAGS"
    fi

    CFLAGS="$opt_flags"
    CXXFLAGS="-std=c++${JSC_TOOLCHAIN_CXX_STANDARD:-23} $opt_flags"

    local ldflags="$JSC_TOOLCHAIN_RELEASE_LDFLAGS"
    if [[ $HAS_CLANG -eq 0 && "$ldflags" == "-flto=thin" ]]; then
      ldflags="-flto"
    fi
    LDFLAGS="$ldflags"
  else
    CFLAGS="-g2"
    CXXFLAGS="-std=c++${JSC_TOOLCHAIN_CXX_STANDARD:-23}"
    LDFLAGS=""
  fi

  ICU_FILTER_FILE="${TARGETDIR}/icu/filters/android.json"
  local CONFIG_ENV=(env "CFLAGS=$CFLAGS" "CXXFLAGS=$CXXFLAGS")
  if [[ -n "$LDFLAGS" ]]; then
    CONFIG_ENV+=("LDFLAGS=$LDFLAGS")
  fi
  if [[ $HAS_CLANG -eq 1 ]]; then
    local cc_cmd="clang"
    local cxx_cmd="clang++"
    if [[ -n "$JSC_CCACHE_BIN" ]]; then
      cc_cmd="$JSC_CCACHE_BIN clang"
      cxx_cmd="$JSC_CCACHE_BIN clang++"
    fi
    CONFIG_ENV+=("CC=$cc_cmd" "CXX=$cxx_cmd")
  fi

  if [[ -f "$ICU_FILTER_FILE" ]]; then
    printf "Using ICU data filter: %s\n" "$ICU_FILTER_FILE"
    ICU_DATA_FILTER_FILE="$ICU_FILTER_FILE" \
      "${CONFIG_ENV[@]}" \
      $TARGETDIR/icu/source/runConfigureICU Linux \
      --prefix=$PWD/prebuilts \
      --disable-tests \
      --disable-samples \
      --disable-layout \
      --disable-layoutex
  else
    printf "ICU data filter not found at %s, building without data pruning\n" "$ICU_FILTER_FILE"
    "${CONFIG_ENV[@]}" \
      $TARGETDIR/icu/source/runConfigureICU Linux \
      --prefix=$PWD/prebuilts \
      --disable-tests \
      --disable-samples \
      --disable-layout \
      --disable-layoutex
  fi

  make -j5
  cd $ROOTDIR

  #remove icu headers from WTF, so it won't use them instead of the ones from icu/host/common
  rm -rf "$TARGETDIR"/webkit/Source/WTF/icu
}

patchJsc() {
  printf "\n\n\t\t===================== patch jsc =====================\n\n"
  $SCRIPT_DIR/patch.sh jsc
}

prep() {
  echo -e '\033]2;'prep'\007'
  printf "\n\n\t\t===================== copy downloaded sources =====================\n\n"
  rm -rf $TARGETDIR
  cp -Rf $ROOTDIR/build/download $TARGETDIR

  patchAndMakeICU
  patchJsc
  # origs=$(find $ROOTDIR/build/target -name "*.orig")
  # [ -z "$origs" ] || { echo "orig files: $origs" 1>&2 ; exit 1; }
}

compile() {
  printf "\n\n\t\t===================== starting to compile all archs for i18n="${I18N}" =====================\n\n"
  local var="INSTALL_DIR_I18N_${I18N}"
  export INSTALL_DIR_I18N=${!var}
  local var="INSTALL_UNSTRIPPED_DIR_I18N_${I18N}"
  export INSTALL_UNSTRIPPED_DIR_I18N=${!var}
  rm -rf $INSTALL_DIR_I18N
  rm -rf $INSTALL_UNSTRIPPED_DIR_I18N
  $ROOTDIR/scripts/compile/all.sh
}

createAAR() {
  local target=$1
  local distDir=$2
  local jniLibsDir=$3
  local i18n=$4
  local headersDir=${distDir}/include
  printf "\n\n\t\t===================== create aar :${target}: =====================\n\n"
  (
    cd $ROOTDIR/lib
    if [[ -n "$JAVA_HOME" && -x "$JAVA_HOME/bin/java" ]]; then
      export JAVA_HOME
      export PATH="$JAVA_HOME/bin:$PATH"
    else
      echo "Warning: JAVA_HOME not set or invalid when invoking Gradle" >&2
    fi
    if [[ -n "$JAVA_HOME" ]]; then
      export GRADLE_OPTS="${GRADLE_OPTS} -Dorg.gradle.java.home=$JAVA_HOME"
    fi
    ./gradlew clean :${target}:publish \
        --project-prop distDir="${distDir}" \
        --project-prop jniLibsDir="${jniLibsDir}" \
        --project-prop headersDir="${headersDir}" \
        --project-prop version="${npm_package_version}" \
        --project-prop i18n="${i18n}"
  )
}

copyHeaders() {
  local distDir=$1
  printf "\n\n\t\t===================== adding headers to ${distDir}/include =====================\n\n"
  mkdir -p ${distDir}/include
  cp -Rf $TARGETDIR/webkit/Source/JavaScriptCore/API/*.h ${distDir}/include
}

if [[ "${SKIP_NO_INTL}" != "1" ]]; then
  export I18N=false
  prep
  compile
fi

if [[ "${SKIP_INTL}" != "1" ]]; then
  export I18N=true
  prep
  compile
fi

printf "\n\n\t\t===================== create stripped distributions =====================\n\n"
export DISTDIR=${STRIPPED_DIST_DIR}
copyHeaders ${DISTDIR}
createAAR "jsc-android" ${DISTDIR} ${INSTALL_DIR_I18N_false} "false"
createAAR "jsc-android" ${DISTDIR} ${INSTALL_DIR_I18N_true} "true"
createAAR "cppruntime" ${DISTDIR} ${INSTALL_CPPRUNTIME_DIR} "false"

printf "\n\n\t\t===================== create unstripped distributions =====================\n\n"
export DISTDIR=${UNSTRIPPED_DIST_DIR}
copyHeaders ${DISTDIR}
createAAR "jsc-android" ${DISTDIR} ${INSTALL_UNSTRIPPED_DIR_I18N_false} "false"
createAAR "jsc-android" ${DISTDIR} ${INSTALL_UNSTRIPPED_DIR_I18N_true} "true"
createAAR "cppruntime" ${DISTDIR} ${INSTALL_CPPRUNTIME_DIR} "false"

printf "\n\n\t\t===================== build smoke test assets =====================\n\n"
if ! "${ROOTDIR}/scripts/build-js-smoketest.sh"; then
  echo "Failed to build smoke test assets for ${JSC_TOOLCHAIN_VARIANT}" >&2
  exit 1
fi

npm run info

echo "I am not slacking off, my code is compiling."
