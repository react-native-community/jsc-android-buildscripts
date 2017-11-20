#!/bin/bash -e

source './common.sh'

ICU_VERSION="56.1"

BUILD_DIR=$ROOTDIR/target/icu/${CROSS_COMPILE_PLATFORM}-${FLAVOR}
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

CROSS_BUILD_DIR=$(realpath ../host)
PATH=$TOOLCHAIN_DIR/bin:$PATH

../source/configure --prefix=$(pwd)/prebuilts \
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
    --with-data-packaging=library

make -j5

if [[ $ENABLE_INTL ]]; then
    cp lib/libicudata_jsc.so $INSTALL_DIR/libicudata_jsc.so
    cp lib/libicui18n_jsc.so.$ICU_VERSION $INSTALL_DIR/libicui18n_jsc.so
else
    rm lib/libicui18n_jsc.so*
    cp stubdata/libicudata_jsc.so.$ICU_VERSION lib/
    cp stubdata/libicudata_jsc.so.$ICU_VERSION $INSTALL_DIR/libicudata_jsc.so
fi

cp lib/libicuuc_jsc.so.$ICU_VERSION $INSTALL_DIR/libicuuc_jsc.so
