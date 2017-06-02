#!/bin/bash

ROOTDIR=`pwd`
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
PLATFORM_CFLAGS_arm=" \
-march=armv7-a \
-mfloat-abi=softfp \
-mfpu=neon \
-mthumb \
"

PLATFORM_LDFLAGS_arm=" \
-L$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib/armv7-a \
-march=armv7-a \
-Wl,--fix-cortex-a8 \
"

PLATFORM_LDFLAGS_arm64=" \
-L$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib \
"

PLATFORM_LDFLAGS_x86=" \
-L$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib \
"

PLATFORM_LDFLAGS_x86_64=" \
-L$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib \
"

# arch
var="PLATFORM_CFLAGS_$JSC_ARCH"
PLATFORM_CFLAGS=${!var}
var="PLATFORM_LDFLAGS_$JSC_ARCH"
PLATFORM_LDFLAGS=${!var}

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

ICU_CFLAGS="$COMMON_CFLAGS $PLATFORM_CFLAGS"
ICU_CXXFLAGS="$COMMON_CXXFLAGS $ICU_CFLAGS"
ICU_LDFLAGS="$COMMON_LDFLAGS $PLATFORM_LDFLAGS"

