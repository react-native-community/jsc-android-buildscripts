#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)
source $SCRIPT_DIR/common.sh

BUILD_DIR=$TARGETDIR/plist/${CROSS_COMPILE_PLATFORM}-${FLAVOR}

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# CROSS_BUILD_DIR=$(realpath ../host)
export PATH=$TOOLCHAIN_DIR/bin:$PATH
../configure \
    --with-sysroot="$TOOLCHAIN_DIR/sysroot" \
    --without-cython \
    --host=$CROSS_COMPILE_PLATFORM \
    CFLAGS="$COMMON_CFLAGS" \
    CXXFLAGS="$COMMON_CXXFLAGS" \
    LDFLAGS="$PLATFORM_LDFLAGS -lc++_shared -lm" \
    CC=$CROSS_COMPILE_PLATFORM-clang \
    CXX=$CROSS_COMPILE_PLATFORM-clang++ \
    AR=$CROSS_COMPILE_PLATFORM-ar \
    AS=$CROSS_COMPILE_PLATFORM-clang \
    RINLIB=$CROSS_COMPILE_PLATFORM-ranlib

make -j5 VERBOSE=1

cp src/.libs/libplist.so $INSTALL_DIR/libplist.so
cp src/.libs/libplist++.so $INSTALL_DIR/libplist++.so
