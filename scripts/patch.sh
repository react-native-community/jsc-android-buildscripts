#!/bin/bash -e
PATCHES_DIR=$ROOTDIR/patches

######################################################################################
# Patchset management that manage files by commented purpose
######################################################################################
ICU_PATCHSET=(
  # Basic build setup for JSC on Android
  "icu.patch"
)

JSC_PATCHSET=(
  # Basic build setup, e.g. libjsc.so output name
  "jsc.patch"

  # Feature toggles, e.g. disable unnecessary build or JIT settings
  "jsc_features.patch"

  # NDK does not support backtrace and execinfo.h
  "jsc_fix_build_error_execinfo.patch"

  # NDK API 16 does not have getline().
  # Since the WTF MemoryFootprint is not used in JSC, comment out all the code.
  "jsc_fix_build_error_getline.patch"

  # NDK API 16 does not have log2().
  # Add custom polyfill
  "jsc_fix_build_error_log2.patch"

  # NDK API 16 does not have posix_memalign
  "jsc_fix_build_error_memalign.patch"

  # Fix build error which related to C++StringView
  "jsc_fix_build_error_stringview.patch"

  # Integrate with Chromium ICU
  "jsc_icu_integrate.patch"

  # Support getting correct locale setting in Android system
  "jsc_locale_support.patch"

  # Will print current JSC version in adb log during initialization
  "jsc_startup_log_version.patch"

  # NDK r17c does not define __mulodi4, which is being used in debug build.
  # (However, NDK r19 fixed this)
  "jsc_fix_build_error_mulodi4.patch"

  # Fix build error if disabling DFG_JIT
  "jsc_fix_build_error_disable_dfg.patch"
)

if [[ "$I18N" = false ]]
then
  JSC_PATCHSET+=(
    # Disable i18n for non-i18n build
    "jsc_disable_icu.patch"
  )
fi

######################################################################################
# Patchset management end
######################################################################################

TARGET=$1

if [[ "$TARGET" == "jsc" ]]
then
  for patch in "${JSC_PATCHSET[@]}"
  do
    printf "### Patch set: $patch\n"
    patch -d $TARGETDIR -p1 < $PATCHES_DIR/$patch
  done
elif [[ "$TARGET" == "icu" ]]
then
  for patch in "${ICU_PATCHSET[@]}"
  do
    printf "### Patch set: $patch\n"
    patch -d $TARGETDIR -p1 < $PATCHES_DIR/$patch
  done
else
    printf "Usage: $0 (icu|jsc)\n"
    exit 1
fi
