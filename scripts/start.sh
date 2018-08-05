#!/bin/bash -e

ROOTDIR=$PWD
TARGETDIR=$ROOTDIR/build/target
REVISION=$(svn info --show-item last-changed-revision "https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}")

prep() {
  printf "\n\n\t\t===================== copy downloaded sources =====================\n\n"
  rm -rf $TARGETDIR
  cp -Rf $ROOTDIR/build/download $TARGETDIR

  printf "\n\n\t\t===================== patch and make icu into target/icu/host =====================\n\n"
  ICU_VERSION_MAJOR="$(awk '/ICU_VERSION_MAJOR_NUM/ {print $3}' $TARGETDIR/icu/source/common/unicode/uvernum.h)"
  printf "ICU version: ${ICU_VERSION_MAJOR}\n"
  patch -d $TARGETDIR -p1 < $ROOTDIR/patches/icu.patch

  # use compiled .dat archive from Android Chromium
  cp $TARGETDIR/icu/android/icudtl.dat $TARGETDIR/icu/source/data/in/icudt${ICU_VERSION_MAJOR}l.dat
  rm $TARGETDIR/icu/source/data/translit/root_subset.txt $TARGETDIR/icu/source/data/translit/trnslocal.mk

  rm -rf $TARGETDIR/icu/host
  mkdir -p $TARGETDIR/icu/host
  cd $TARGETDIR/icu/host
  $TARGETDIR/icu/source/runConfigureICU Linux --prefix=$PWD/prebuilts CFLAGS="-Os" CXXFLAGS="--std=c++11" --disable-tests --disable-samples
  make -j5
  cd $ROOTDIR

  printf "\n\n\t\t===================== patch jsc =====================\n\n"
  patch -d $TARGETDIR -p1 < $ROOTDIR/patches/jsc.patch

  # disable i18n for non-i18n build
  if ${I18N}
  then
    patch -d $TARGETDIR -N -p1 < $ROOTDIR/patches/intl/icu-disabled.patch
  fi

  #remove icu headers from WTF, so it won't use them instead of the ones from icu/host/common
  rm -rf "$TARGETDIR"/webkit/Source/WTF/icu

  printf "orig: $(find $ROOTDIR/build/target | grep \.orig || true)\n"
}

compile() {
  printf "\n\n\t\t===================== compile jsc =====================\n\n"
  rm -rf $ROOTDIR/build/compiled
  $ROOTDIR/scripts/compile/all.sh
}

createAAR() {
  printf "\n\n\t\t===================== create aar =====================\n\n"
  cd $ROOTDIR/lib
  ./gradlew clean createAAR --project-prop revision="$REVISION" --project-prop i18n="${I18N}"
  cd $ROOTDIR
}

export I18N=false
prep
compile
createAAR

export I18N=true
prep
compile
createAAR

npm run info
echo "I am not slacking off, my code is compiling."
