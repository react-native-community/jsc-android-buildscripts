#!/bin/bash -ex

ROOTDIR=$PWD
TARGETDIR=$ROOTDIR/build/target

echo "=============== copy downloaded sources ====================="
rm -rf $TARGETDIR
cp -Rf $ROOTDIR/build/download $TARGETDIR

echo "=============== patch and make icu into target/icu/host ====================="
patch -d $TARGETDIR -p1 < $ROOTDIR/patches/icu.patch

rm -rf $TARGETDIR/icu/host
mkdir -p $TARGETDIR/icu/host
cd $TARGETDIR/icu/host
$TARGETDIR/icu/source/runConfigureICU Linux --prefix=$PWD/prebuilts CFLAGS="-Os" CXXFLAGS="--std=c++11"
make -j5
cd $ROOTDIR

echo "=============== patch jsc ====================="
patch -d $TARGETDIR -p1 < $ROOTDIR/patches/jsc.patch
