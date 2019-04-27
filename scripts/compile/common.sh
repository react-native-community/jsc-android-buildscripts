#!/bin/bash -e

# functions
fix_zero_value_flag() {
  flag=$1
  var="ENABLE_$flag"
  if [[ ${!var} == 0 ]]; then unset "$var"; fi
}

process_switch_options() {
  flag=$1
  var="ENABLE_$flag"
  if [[ ${!var} ]]; then
    suffix="ON"
  else
    suffix="OFF"
  fi
  var2="SWITCH_COMMON_CFLAGS_${flag}_${suffix}"
  readonly "SWITCH_COMMON_CFLAGS_${flag}"="${!var2}"
  var2="SWITCH_BUILD_WEBKIT_OPTIONS_${flag}_${suffix}"
  readonly "SWITCH_BUILD_WEBKIT_OPTIONS_${flag}"="${!var2}"
  var2="SWITCH_BUILD_WEBKIT_CMAKE_ARGS_${flag}_${suffix}"
  readonly "SWITCH_BUILD_WEBKIT_CMAKE_ARGS_${flag}"="${!var2}"
  var2="SWITCH_JSC_CFLAGS_${flag}_${suffix}"
  readonly "SWITCH_JSC_CFLAGS_${flag}"="${!var2}"
}

if ! [[ $ROOTDIR ]]; then ROOTDIR=`pwd`; fi
ARCH=$JSC_ARCH

TARGETDIR=$ROOTDIR/build/target

# platform specific settings
CROSS_COMPILE_PLATFORM_arm="arm-linux-androideabi"
CROSS_COMPILE_PLATFORM_arm64="aarch64-linux-android"
CROSS_COMPILE_PLATFORM_x86="i686-linux-android"
CROSS_COMPILE_PLATFORM_x86_64="x86_64-linux-android"

# arch
var="CROSS_COMPILE_PLATFORM_$JSC_ARCH"
CROSS_COMPILE_PLATFORM=${!var}
TOOLCHAIN_DIR=$TARGETDIR/toolchains/$CROSS_COMPILE_PLATFORM

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

TOOLCHAIN_LINK_DIR_x86_64="$TOOLCHAIN_DIR/$CROSS_COMPILE_PLATFORM/lib64"
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

# options flags
# INTL
SWITCH_COMMON_CFLAGS_INTL_OFF="-DUCONFIG_NO_COLLATION=1 -DUCONFIG_NO_FORMATTING=1"
SWITCH_BUILD_WEBKIT_OPTIONS_INTL_OFF="--no-intl"
SWITCH_BUILD_WEBKIT_OPTIONS_INTL_ON="--intl"

# switches
fix_zero_value_flag "INTL"
process_switch_options "INTL"

# checks
err=false
if ! [[ $ANDROID_API_FOR_ABI_32 ]]; then echo "set ANDROID_API_FOR_ABI_32 to the minimum supported Android platform version for arm and x86 (e.g. 16)"; err=true; fi
if ! [[ $ANDROID_API_FOR_ABI_64 ]]; then echo "set ANDROID_API_FOR_ABI_64 to the minimum supported Android platform version for arm64 and x86_64 (e.g. 21)"; err=true; fi
if ! [[ $FLAVOR ]]; then echo "set FLAVOR to the name of the flavor"; err=true; fi
if ! [[ $CROSS_COMPILE_PLATFORM ]]; then echo "set JSC_ARCH to one of {arm,arm64,x86,x86_64}"; err=true; fi
if ! [[ $ANDROID_HOME ]]; then echo "set ANDROID_HOME to android sdk dir"; err=true; fi
if ! [[ $ANDROID_NDK ]]; then echo "set ANDROID_NDK to android ndk dir"; err=true; fi

if [[ $err = true ]]; then exit 1; fi

####

DEBUG_SYMBOL_LEVEL="-g2"
if [[ "$BUILD_TYPE" = "Release" ]]
then
    FRAME_POINTER_FLAG="-fomit-frame-pointer"
    CFLAGS_BUILD_TYPE="-DNDEBUG"
    ICU_CFLAGS_BUILD_TYPE="-Oz"
else
    FRAME_POINTER_FLAG="-fno-omit-frame-pointer"
    CFLAGS_BUILD_TYPE=""
    ICU_CFLAGS_BUILD_TYPE=$DEBUG_SYMBOL_LEVEL
fi

####

COMMON_LDFLAGS=" \
-Wl,-z,noexecstack \
-Wl,--gc-sections \
-Wl,--exclude-libs,libgcc.a \
-Wl,--exclude-libs,libunwind.a \
-Wl,--no-undefined \
"

COMMON_CFLAGS=" \
-fstack-protector \
-ffunction-sections \
$FRAME_POINTER_FLAG \
-fno-strict-aliasing \
-funwind-tables \
-DPIC \
-fPIC \
-fvisibility=hidden \
-DCUSTOMIZE_REACT_NATIVE \
$SWITCH_COMMON_CFLAGS_INTL \
$CFLAGS_BUILD_TYPE \
"

COMMON_CXXFLAGS=" \
"

ICU_CFLAGS="$COMMON_CFLAGS $PLATFORM_CFLAGS $ICU_CFLAGS_BUILD_TYPE"
ICU_CXXFLAGS="$COMMON_CXXFLAGS $ICU_CFLAGS $ICU_CFLAGS_BUILD_TYPE"
ICU_LDFLAGS="$COMMON_LDFLAGS \
-fuse-ld=gold \
-Wl,--icf=safe \
$PLATFORM_LDFLAGS \
"

JSC_LDFLAGS="$COMMON_LDFLAGS"
JSC_CFLAGS="$COMMON_CFLAGS -DU_STATIC_IMPLEMENTATION=1 -DU_SHOW_CPLUSPLUS_API=0"

INSTALL_DIR=$ROOTDIR/build/compiled/$JNI_ARCH
mkdir -p $INSTALL_DIR

INSTALL_CPPRUNTIME_DIR=$ROOTDIR/build/cppruntime/$JNI_ARCH
mkdir -p $INSTALL_CPPRUNTIME_DIR
