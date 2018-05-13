#!/bin/bash -ex

ROOTDIR=$PWD
TARGETDIR=$ROOTDIR/build/target

echo "=============== prepare downloaded sources ====================="
rm -rf $TARGETDIR
cp -Rf $ROOTDIR/build/download $TARGETDIR

echo "=============== prepare gradle version ====================="
VERSION_NAME=$($ROOTDIR/scripts/version.sh)
echo $VERSION_NAME
sed -i '' -e "s/VERSION_NAME=.+/VERSION_NAME=${VERSION_NAME}/" $ROOTDIR/lib/lib/gradle.properties $ROOTDIR/lib/libIntl/gradle.properties

echo "=============== prepare icu ====================="
patch -d $TARGETDIR -p1 < $ROOTDIR/patches/icu.patch

rm -rf $TARGETDIR/icu/host
mkdir -p $TARGETDIR/icu/host
cd $TARGETDIR/icu/host
$TARGETDIR/icu/source/runConfigureICU Linux --prefix=$PWD/prebuilts CFLAGS="-Os" CXXFLAGS="--std=c++11"
make -j5
cd $ROOTDIR

echo "=============== prepare jsc ====================="
patch -d $TARGETDIR -p1 < $ROOTDIR/patches/jsc.patch
