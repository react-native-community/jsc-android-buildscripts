#!/bin/bash -e

source ./scripts/calc-version.sh

rm -rf target 
cp -Rf downloaded target

ROOTDIR=`pwd`

echo "=============== prepare version ================="
sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=${VERSION_NAME}/" lib/lib/gradle.properties lib/libIntl/gradle.properties
rm lib/lib/gradle.properties.bak lib/libIntl/gradle.properties.bak

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
