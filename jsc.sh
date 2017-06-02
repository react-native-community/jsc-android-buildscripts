#!/bin/bash

source common.sh

PATH=$TOOLCHAIN_DIR/bin:$ANDROID_HOME/cmake/3.6.3155560/bin/:$PATH

rm -rf target/webkit/WebKitBuild
cd target/webkit/Tools/Scripts

CMAKE_CXX_FLAGS=" \
$COMMON_CFLAGS \
$PLATFORM_CFLAGS \
-fno-rtti \
-I$ROOTDIR/extra_headers/wtf/ \
-I$ROOTDIR/target/icu/source/i18n \
"
CMAKE_LD_FLAGS=" \
-latomic \
-lm \
-lc++_shared \
$COMMON_LDFLAGS \
$PLATFORM_LDFLAGS \
"

./build-webkit \
  --jsc-only \
  --release \
  --jit \
  --intl \
  --no-webassembly \
  --no-xslt \
  --no-netscape-plugin-api \
  --no-tools \
  --cmakeargs="-DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=$ANDROID_API \
  -DCMAKE_SYSTEM_PROCESSOR=$ARCH \
  -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$TOOLCHAIN_DIR \
  -DWEBKIT_LIBRARIES_INCLUDE_DIR=$ROOTDIR/target/icu/source/common \
  -DWEBKIT_LIBRARIES_LINK_DIR=$ROOTDIR/target/icu/$CROSS_COMPILE_PLATFORM/lib \
  -DCMAKE_C_COMPILER=$CROSS_COMPILE_PLATFORM-clang \
  -DCMAKE_CXX_COMPILER=$CROSS_COMPILE_PLATFORM-clang \
  -DCMAKE_SYSROOT=$ANDROID_NDK/platforms/android-$ANDROID_API/arch-$ARCH \
  -DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS} $COMMON_CXXFLAGS $CMAKE_CXX_FLAGS' \
  -DCMAKE_C_FLAGS='${CMAKE_C_FLAGS} $CMAKE_CXX_FLAGS' \
  -DCMAKE_SHARED_LINKER_FLAGS='${CMAKE_SHARED_LINKER_FLAGS} $CMAKE_LD_FLAGS' \
  -DCMAKE_EXE_LINKER_FLAGS='${CMAKE_MODULE_LINKER_FLAGS} $CMAKE_LD_FLAGS' \
  -DENABLE_API_TESTS=0 \
  -DCMAKE_VERBOSE_MAKEFILE=on \
  "

  mv $ROOTDIR/target/webkit/WebKitBuild $ROOTDIR/target/webkit/$CROSS_COMPILE_PLATFORM