#!/bin/bash -e

export ANDROID_API_FOR_ABI_32=24
export ANDROID_API_FOR_ABI_64=24
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

source $ROOTDIR/scripts/env.sh
source $ROOTDIR/scripts/info.sh
export JSC_VERSION=${npm_package_version}
export BUILD_TYPE=Release
# export BUILD_TYPE=Debug

SCRIPT_DIR=$(cd `dirname $0`; pwd)

patchAndMakeICU() {
  printf "\n\n\t\t===================== patch and make icu into target/icu/host =====================\n\n"
  ICU_VERSION_MAJOR="$(awk '/ICU_VERSION_MAJOR_NUM/ {print $3}' $TARGETDIR/icu/source/common/unicode/uvernum.h)"
  printf "ICU version: ${ICU_VERSION_MAJOR}\n"
  $SCRIPT_DIR/patch.sh icu
  rm -rf $TARGETDIR/icu/host
  mkdir -p $TARGETDIR/icu/host
  cd $TARGETDIR/icu/host

  if [[ "$BUILD_TYPE" = "Release" ]]
  then
    local OPT_FLAGS="-O2 -flto=thin -fvectorize -fslp-vectorize -funroll-loops"
    CFLAGS="$OPT_FLAGS"
    CXXFLAGS="-std=c++2b $OPT_FLAGS"
    LDFLAGS="-flto=thin"
  else
    CFLAGS="-g2"
    CXXFLAGS="-std=c++2b"
    LDFLAGS=""
  fi

  ICU_FILTER_FILE="${TARGETDIR}/icu/filters/android.json"
  local CONFIG_ENV=(env "CFLAGS=$CFLAGS" "CXXFLAGS=$CXXFLAGS")
  if [[ -n "$LDFLAGS" ]]; then
    CONFIG_ENV+=("LDFLAGS=$LDFLAGS")
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
  cd $ROOTDIR/lib
  ./gradlew clean :${target}:publish \
      --project-prop distDir="${distDir}" \
      --project-prop jniLibsDir="${jniLibsDir}" \
      --project-prop headersDir="${headersDir}" \
      --project-prop version="${npm_package_version}" \
      --project-prop i18n="${i18n}"
  cd $ROOTDIR
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
export DISTDIR=${ROOTDIR}/dist
copyHeaders ${DISTDIR}
createAAR "jsc-android" ${DISTDIR} ${INSTALL_DIR_I18N_false} "false"
createAAR "jsc-android" ${DISTDIR} ${INSTALL_DIR_I18N_true} "true"
createAAR "cppruntime" ${DISTDIR} ${INSTALL_CPPRUNTIME_DIR} "false"

printf "\n\n\t\t===================== create unstripped distributions =====================\n\n"
export DISTDIR=${ROOTDIR}/dist.unstripped
copyHeaders ${DISTDIR}
createAAR "jsc-android" ${DISTDIR} ${INSTALL_UNSTRIPPED_DIR_I18N_false} "false"
createAAR "jsc-android" ${DISTDIR} ${INSTALL_UNSTRIPPED_DIR_I18N_true} "true"
createAAR "cppruntime" ${DISTDIR} ${INSTALL_CPPRUNTIME_DIR} "false"

npm run info

echo "I am not slacking off, my code is compiling."
