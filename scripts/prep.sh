#!/bin/bash -ex

ROOTDIR=`pwd`

echo "=============== prepare downloaded sources ====================="
rm -rf target
cp -Rf downloaded target

echo "=============== prepare gradle version ====================="
VERSION_NAME=$(./scripts/getVersion.sh)
echo $VERSION_NAME
sed -i '' -e "s/VERSION_NAME=.+/VERSION_NAME=${VERSION_NAME}/" lib/lib/gradle.properties lib/libIntl/gradle.properties

echo "=============== prepare icu ====================="
patch -p0 < $ROOTDIR/patches/icu.patch

rm -rf $ROOTDIR/target/icu/host
mkdir -p $ROOTDIR/target/icu/host
cd $ROOTDIR/target/icu/host

../source/runConfigureICU Linux --prefix=$PWD/prebuilts CFLAGS="-Os" CXXFLAGS="--std=c++11"

make -j5

echo "=============== prepare jsc ====================="
patch -p0 < $ROOTDIR/patches/jsc.patch
