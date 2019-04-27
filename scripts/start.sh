#!/bin/bash -e

export ANDROID_API_FOR_ABI_32=16
export ANDROID_API_FOR_ABI_64=21
export ROOTDIR=$PWD
export TARGETDIR=$ROOTDIR/build/target
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

  # use compiled .dat archive from Android Chromium
  cp $TARGETDIR/icu/android/icudtl.dat $TARGETDIR/icu/source/data/in/icudt${ICU_VERSION_MAJOR}l.dat
  rm $TARGETDIR/icu/source/data/translit/root_subset.txt $TARGETDIR/icu/source/data/translit/trnslocal.mk

  rm -rf $TARGETDIR/icu/host
  mkdir -p $TARGETDIR/icu/host
  cd $TARGETDIR/icu/host

  if [[ "$BUILD_TYPE" = "Release" ]]
  then
    CFLAGS="-Os"
  else
    CFLAGS="-g2"
  fi

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
  rm -rf $ROOTDIR/build/compiled
  $ROOTDIR/scripts/compile/all.sh
}

createAAR() {
  TARGET=$1
  printf "\n\n\t\t===================== create aar :$TARGET: =====================\n\n"
  cd $ROOTDIR/lib
  ./gradlew clean :$TARGET:createAAR --project-prop revision="$REVISION" --project-prop i18n="${I18N}"
  cd $ROOTDIR
  unset TARGET
}

copyHeaders() {
  printf "\n\n\t\t===================== adding headers to $ROOTDIR/dist/include =====================\n\n"
  mkdir -p $ROOTDIR/dist/include
  cp -Rf $TARGETDIR/webkit/Source/JavaScriptCore/API/*.h $ROOTDIR/dist/include
}

export I18N=false
prep
compile
createAAR "android-jsc"

export I18N=true
prep
compile
createAAR "android-jsc"

createAAR "cppruntime"

copyHeaders

npm run info

echo "I am not slacking off, my code is compiling."
