#!/bin/bash

ROOTDIR=`pwd`

patch -p0 < $ROOTDIR/patches/icu.patch

rm -rf $ROOTDIR/target/icu/host
mkdir -p $ROOTDIR/target/icu/host
cd $ROOTDIR/target/icu/host

../source/runConfigureICU Linux --prefix=$PWD/prebuilts \
    CFLAGS="-Os" \
    CXXFLAGS="--std=c++11"
    # maybe speedup compilation somehow
make -j5
