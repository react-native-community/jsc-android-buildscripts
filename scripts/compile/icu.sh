#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)
source $SCRIPT_DIR/common.sh

# Get the ICU version from the single source of truth as defined in icu4c/source/configure
geticuversion() {
    sed -n 's/^[ 	]*#[ 	]*define[ 	]*U_ICU_VERSION[ 	]*"\([^"]*\)".*/\1/p' "$@"
}
ICU_VERSION=`geticuversion $TARGETDIR/icu/source/common/unicode/uvernum.h`
echo "===================== detected ICU_VERSION: ${ICU_VERSION} ======================="

BUILD_DIR=$TARGETDIR/icu/${CROSS_COMPILE_PLATFORM}-${FLAVOR}
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

CROSS_BUILD_DIR=$(realpath $TARGETDIR/icu/host)
PATH=$TOOLCHAIN_DIR/bin:$PATH
INSTALL_DIR=${BUILD_DIR}/prebuilts

if [[ "$BUILD_TYPE" = "Release" ]]
then
    BUILD_TYPE_CONFIG="--enable-release=yes"
else
    BUILD_TYPE_CONFIG="--enable-debug=yes"
fi

ICU_DATA_FILTER_FILE="${TARGETDIR}/icu/filters/android.json" \
$TARGETDIR/icu/source/configure --prefix=${INSTALL_DIR} \
    $BUILD_TYPE_CONFIG \
    --host=$CROSS_COMPILE_PLATFORM \
    --enable-static=yes \
    --enable-shared=no \
    --enable-extras=no \
    --enable-strict=no \
    --enable-icuio=no \
    --enable-layout=no \
    --enable-layoutex=no \
    --enable-tests=no \
    --enable-samples=no \
    --enable-dyload=no \
    --with-cross-build=$CROSS_BUILD_DIR \
    CFLAGS="$ICU_CFLAGS" \
    CXXFLAGS="$ICU_CXXFLAGS" \
    LDFLAGS="$ICU_LDFLAGS" \
    CC=$CROSS_COMPILE_PLATFORM_CC-clang \
    CXX=$CROSS_COMPILE_PLATFORM_CC-clang++ \
    AR=$TOOLCHAIN_DIR/bin/llvm-ar \
    LD=$TOOLCHAIN_DIR/bin/ld \
    RANLIB=$TOOLCHAIN_DIR/bin/llvm-ranlib \
    STRIP=$TOOLCHAIN_DIR/bin/llvm-strip \
    --with-data-packaging=static

make -j5 install

if ! [[ $ENABLE_INTL ]]; then
  cp stubdata/libicudata.a ${INSTALL_DIR}/lib/
fi
