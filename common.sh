#!/bin/bash

if ! [[ $ROOTDIR ]]; then ROOTDIR=`pwd`; fi
ARCH=$JSC_ARCH

ANDROID_API=21

# platform specific settings

CROSS_COMPILE_PLATFORM_arm="arm-linux-androideabi"
CROSS_COMPILE_PLATFORM_arm64="aarch64-linux-android"
CROSS_COMPILE_PLATFORM_x86="i686-linux-android"
CROSS_COMPILE_PLATFORM_x86_64="x86_64-linux-android"

# arch
var="CROSS_COMPILE_PLATFORM_$JSC_ARCH"
CROSS_COMPILE_PLATFORM=${!var}
TOOLCHAIN_DIR=$ROOTDIR/target/toolchains/$CROSS_COMPILE_PLATFORM

# settings
TOOLCHAIN_LINK_DIR_arm="$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib/armv7-a"
PLATFORM_CFLAGS_arm=" \
-march=armv7-a \
-mfloat-abi=softfp \
-mfpu=neon \
-mthumb \
"
PLATFORM_LDFLAGS_arm=" \
-L$TOOLCHAIN_LINK_DIR_arm \
-march=armv7-a \
-Wl,--fix-cortex-a8 \
"
JNI_ARCH_arm=armeabi-v7a

TOOLCHAIN_LINK_DIR_arm64="$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib"
PLATFORM_LDFLAGS_arm64=" \
-L$TOOLCHAIN_LINK_DIR_arm64 \
"
JNI_ARCH_arm64=arm64-v8a

TOOLCHAIN_LINK_DIR_x86="$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib"
PLATFORM_CFLAGS_x86=" \
-march=i686 \
-mtune=intel \
-mssse3 \
-mfpmath=sse \
-m32 \
"
PLATFORM_LDFLAGS_x86=" \
-L$TOOLCHAIN_LINK_DIR_x86 \
"
JNI_ARCH_x86=x86

TOOLCHAIN_LINK_DIR_x86_64="$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib"
PLATFORM_CFLAGS_x86_64=" \
-march=x86-64 \
-msse4.2 \
-mpopcnt \
-m64 \
-mtune=intel \
"
PLATFORM_LDFLAGS_x86_64=" \
-L$TOOLCHAIN_LINK_DIR_x86_64 \
"
JNI_ARCH_x86_64=x86_64

# arch
var="PLATFORM_CFLAGS_$JSC_ARCH"
PLATFORM_CFLAGS=${!var}
var="PLATFORM_LDFLAGS_$JSC_ARCH"
PLATFORM_LDFLAGS=${!var}
var="JNI_ARCH_$JSC_ARCH"
JNI_ARCH=${!var}
var="TOOLCHAIN_LINK_DIR_$JSC_ARCH"
TOOLCHAIN_LINK_DIR=${!var}

# checks
err=false
if ! [[ $CROSS_COMPILE_PLATFORM ]]; then echo "set JSC_ARCH to one of {arm,arm64,x86,x86_64}"; err=true; fi
if ! [[ $ANDROID_HOME ]]; then echo "set ANDROID_HOME to android sdk dir"; err=true; fi
if ! [[ $ANDROID_NDK ]]; then echo "set ANDROID_NDK to android ndk dir"; err=true; fi

if [[ $err = true ]]; then exit 1; fi

####

COMMON_LDFLAGS=" \
-fuse-ld=gold \
-Wl,--icf=safe \
-Wl,-z,noexecstack \
-s \
"

COMMON_CFLAGS=" \
-fstack-protector \
-ffunction-sections \
-fomit-frame-pointer \
-fno-strict-aliasing \
-fno-exceptions \
-funwind-tables \
-DPIC \
-fPIC \
-fvisibility=hidden \
-DNDEBUG \
"

COMMON_CXXFLAGS=" \
--std=c++11 \
"

ICU_CFLAGS="$COMMON_CFLAGS $PLATFORM_CFLAGS -Os"
ICU_CXXFLAGS="$COMMON_CXXFLAGS $ICU_CFLAGS -Os"
ICU_LDFLAGS="$COMMON_LDFLAGS $PLATFORM_LDFLAGS"

INSTALL_DIR=$ROOTDIR/lib/distribution/jsc/lib/$JNI_ARCH
mkdir -p $INSTALL_DIR
