#!/bin/bash -e

ROOTDIR=$PWD
TARGETDIR=$ROOTDIR/build/target

echo "=============== copy downloaded sources ====================="
rm -rf $TARGETDIR
cp -Rf $ROOTDIR/build/download $TARGETDIR

echo "=============== patch and make icu into target/icu/host ====================="
ICU_VERSION_MAJOR="$(awk '/ICU_VERSION_MAJOR_NUM/ {print $3}' $TARGETDIR/icu/source/common/unicode/uvernum.h)"
echo "ICU version: ${ICU_VERSION_MAJOR}"
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

echo "=============== patch jsc ====================="
patch -d $TARGETDIR -p1 < $ROOTDIR/patches/jsc.patch

# conditional patch
if [[ "$npm_package_config_i18n" = false ]]; then
  patch -d $TARGETDIR -N -p1 < $ROOTDIR/patches/intl/icu-disabled.patch
fi

#remove icu headers from WTF, so it won't use them instead of the ones from icu/host/common
rm -rf "$TARGETDIR"/webkit/Source/WTF/icu
echo "orig: $(find $ROOTDIR/build/target | grep \.orig || true)"
