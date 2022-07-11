#!/bin/bash -e

export ANDROID_API_FOR_ABI_32=21
export ANDROID_API_FOR_ABI_64=21
export ROOTDIR=$PWD

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
    CFLAGS="-Os"
  else
    CFLAGS="-g2"
  fi

  ICU_DATA_FILTER_FILE="${TARGETDIR}/icu/filters/android.json" \
  $TARGETDIR/icu/source/runConfigureICU Linux \
  --prefix=$PWD/prebuilts \
  CFLAGS="$CFLAGS" \
  CXXFLAGS="--std=c++11" \
  --disable-tests \
  --disable-samples \
  --disable-layout \
  --disable-layoutex

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
  printf "\n\n\t\t===================== create aar :${target}: =====================\n\n"
  cd $ROOTDIR/lib
  ./gradlew clean :${target}:createAAR \
      --project-prop distDir="${distDir}" \
      --project-prop jniLibsDir="${jniLibsDir}" \
      --project-prop revision="$REVISION" \
      --project-prop i18n="${i18n}"
  cd $ROOTDIR
}

copyHeaders() {
  local distDir=$1
  printf "\n\n\t\t===================== adding headers to ${distDir}/include =====================\n\n"
  mkdir -p ${distDir}/include
  cp -Rf $TARGETDIR/webkit/Source/JavaScriptCore/API/*.h ${distDir}/include
}

export I18N=true
prep
compile

export DISTDIR=${ROOTDIR}/dist
printf "\n\n\t\t===================== create stripped distributions =====================\n\n"
createAAR "android-jsc" ${DISTDIR} ${INSTALL_DIR_I18N_true} "true"
copyHeaders ${DISTDIR}

printf "\n\n\t\t===================== create unstripped distributions =====================\n\n"
export DISTDIR=${ROOTDIR}/dist.unstripped
createAAR "android-jsc" ${DISTDIR} ${INSTALL_UNSTRIPPED_DIR_I18N_true} "true"
copyHeaders ${DISTDIR}

npm run info

echo "I am not slacking off, my code is compiling."
