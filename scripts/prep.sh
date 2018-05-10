#!/bin/bash -ex

ROOTDIR=$PWD

echo "=============== prepare downloaded sources ====================="
rm -rf $ROOTDIR/target
cp -Rf $ROOTDIR/downloaded $ROOTDIR/target

echo "=============== prepare gradle version ====================="
VERSION_NAME=$($ROOTDIR/scripts/getVersion.sh)
echo $VERSION_NAME
sed -i '' -e "s/VERSION_NAME=.+/VERSION_NAME=${VERSION_NAME}/" $ROOTDIR/lib/lib/gradle.properties $ROOTDIR/lib/libIntl/gradle.properties

echo "=============== prepare icu ====================="
patch -p0 < $ROOTDIR/patches/icu.patch

rm -rf $ROOTDIR/target/icu/host
mkdir -p $ROOTDIR/target/icu/host
cd $ROOTDIR/target/icu/host
$ROOTDIR/target/icu/source/runConfigureICU Linux --prefix=$PWD/prebuilts CFLAGS="-Os" CXXFLAGS="--std=c++11"
make -j5
cd $ROOTDIR

echo "=============== prepare jsc ====================="
patch -p0 < $ROOTDIR/patches/jsc.patch
