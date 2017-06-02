#!/bin/bash

source './common.sh'

rm -rf $ROOTDIR/target/icu/$CROSS_COMPILE_PLATFORM
mkdir -p $ROOTDIR/target/icu/$CROSS_COMPILE_PLATFORM
cd $ROOTDIR/target/icu/$CROSS_COMPILE_PLATFORM

CROSS_BUILD_DIR=$(realpath ../host)
PATH=$TOOLCHAIN_DIR/bin:$PATH

../source/configure --prefix=$(pwd)/prebuilt \
    --host=$CROSS_COMPILE_PLATFORM \
    --enable-shared=yes \
    --enable-extras=no \
    --enable-strict=no \
    --enable-icuio=no \
    --enable-layout=no \
    --enable-layoutex=no \
    --enable-tools=no \
    --enable-tests=no \
    --enable-samples=no \
    --enable-dyload=no \
    -with-cross-build=$CROSS_BUILD_DIR \
    CFLAGS="$ICU_CFLAGS" \
    CXXFLAGS="$ICU_CXXFLAGS" \
    LDFLAGS="$ICU_LDFLAGS" \
    CC=$CROSS_COMPILE_PLATFORM-clang \
    CXX=$CROSS_COMPILE_PLATFORM-clang++ \
    AR=$CROSS_COMPILE_PLATFORM-ar \
    RINLIB=$CROSS_COMPILE_PLATFORM-ranlib \
    --with-data-packaging=archive

make -j5

cp stubdata/lib* lib/