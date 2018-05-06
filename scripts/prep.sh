#!/bin/bash -e

ROOTDIR=`pwd`

VERSION_NAME=$(node -p "require('./scripts/getVersion')()")
node -p "require('./scripts/updateGradleVersion')('${VERSION_NAME}')"

rm -rf target
cp -Rf downloaded target

echo "=============== prepare icu ====================="
patch -p0 < $ROOTDIR/patches/icu.patch

rm -rf $ROOTDIR/target/icu/host
mkdir -p $ROOTDIR/target/icu/host
cd $ROOTDIR/target/icu/host

../source/runConfigureICU Linux --prefix=$PWD/prebuilts \
    CFLAGS="-Os" \
    CXXFLAGS="--std=c++11"
    # maybe speedup compilation somehow
make -j5

echo "=============== prepare jsc ====================="
patch -p0 < $ROOTDIR/patches/jsc.patch
