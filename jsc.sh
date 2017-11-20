#!/bin/bash -e

source common.sh

CMAKE_FOLDER=$(cd $ANDROID_HOME/cmake && ls -1 | sort -r | head -1)
PATH=$TOOLCHAIN_DIR/bin:$ANDROID_HOME/cmake/$CMAKE_FOLDER/bin/:$PATH

# conditional patch
if ! [[ $ENABLE_INTL ]]; then
  patch -p0 < $ROOTDIR/patches/intl/icu-disabled.patch
fi

rm -rf target/webkit/$CROSS_COMPILE_PLATFORM-${FLAVOR}
rm -rf target/webkit/WebKitBuild
cd target/webkit/Tools/Scripts

CMAKE_CXX_FLAGS=" \
$SWITCH_JSC_CFLAGS_COMPAT \
$COMMON_CFLAGS \
$PLATFORM_CFLAGS \
-fno-rtti \
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
  "$SWITCH_BUILD_WEBKIT_OPTIONS_INTL" \
  --no-webassembly \
  --no-xslt \
  --no-netscape-plugin-api \
  --no-tools \
  --cmakeargs="-DCMAKE_SYSTEM_NAME=Android \
  $SWITCH_BUILD_WEBKIT_CMAKE_ARGS_COMPAT \
  -DCMAKE_SYSTEM_VERSION=$ANDROID_API \
  -DCMAKE_SYSTEM_PROCESSOR=$ARCH \
  -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$TOOLCHAIN_DIR \
  -DWEBKIT_LIBRARIES_INCLUDE_DIR=$ROOTDIR/target/icu/source/common \
  -DWEBKIT_LIBRARIES_LINK_DIR=$ROOTDIR/target/icu/${CROSS_COMPILE_PLATFORM}-${FLAVOR}/lib \
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

cp $ROOTDIR/target/webkit/WebKitBuild/Release/lib/libjsc.so $INSTALL_DIR
mv $ROOTDIR/target/webkit/WebKitBuild $ROOTDIR/target/webkit/${CROSS_COMPILE_PLATFORM}-${FLAVOR}
cp $TOOLCHAIN_LINK_DIR/libc++_shared.so $INSTALL_DIR

# conditional patch undo
cd $ROOTDIR
if ! [[ $ENABLE_INTL ]]; then
  patch -p0 -R < $ROOTDIR/patches/intl/icu-disabled.patch
fi
