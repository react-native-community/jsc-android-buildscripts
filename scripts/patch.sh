#!/bin/bash -e
PATCHES_DIR=$ROOTDIR/patches

######################################################################################
# Patchset management that manage files by commented purpose
######################################################################################
ICU_PATCHSET=(
  # Add ICU patchset if needed
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

  # statvfs is provided after NDK API level 19.
  # Use statfs as fallback
  "jsc_fix_build_error_statvfs.patch"

  # Misc errors
  "jsc_fix_build_error_miss_headers.patch"

  # Workaround JIT crash on arm64, especially for Saumsung S7 Edge
  "jsc_fix_arm64_jit_crash.patch"

  # Intl default timezone with Android integration
  "jsc_intl_timezone.patch"

  # Improve heap GC mechanism like iOS
  "jsc_heap_gc_like_ios.patch"

  # GC concurrent issue potential fix
  # https://trac.webkit.org/changeset/251307/webkit
  "jsc_fix_concurrent_gc_issue.patch"

  # enable bigint support
  "jsc_usebigint.patch"
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
