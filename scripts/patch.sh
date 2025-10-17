#!/bin/bash -e
PATCHES_DIR=$ROOTDIR/patches

######################################################################################
# Patchset management that manage files by commented purpose
######################################################################################
ICU_PATCHSET=(
  # Add ICU patchset if needed
)

JSC_PATCHSET=(
  # Android-specific logging for version identification
  "jsc_android_log_version.patch"

  # Ensure PRIu64 fallback matches 64-bit width on Android builds
  "jsc_android_uv_pri64.patch"

  # Fix Collator stub implementation for builds without ICU collation
  "jsc_android_collator_static.patch"

  # Provide defaults for Bun-specific macros on non-Bun platforms
  "jsc_android_define_bun_macros.patch"

  # Update TestWTF to match new ExternalStringImpl signature
  "jsc_fix_external_string_tests.patch"

  # Disable building TestWebKitAPI when consuming JSC only
  "jsc_disable_api_tests.patch"

  # Provide stubs for DFG abstract heap when DFG JIT is disabled
  "jsc_stub_dfg_abstract_heap.patch"

  # Guard async frame helper when Bun additions disabled
  "jsc_async_frame_guard.patch"

  # Guard Bun-specific error helpers when Bun additions are disabled
  "jsc_guard_error_instance.patch"

  # Silence unused parameter warnings in modules and promise helpers
  "jsc_android_silence_unused.patch"

  # Include Android-specific WTF sources for logging and real-time threads
  "jsc_android_wtf_sources.patch"

  # Avoid unused-result warning in CLI wait helper
  "jsc_android_jsc_wait.patch"

  # Guard JIT helpers when DFG/WebAssembly are disabled
  "jsc_android_jit_guards.patch"

  # Avoid ICU formatting dependencies when validating time zones
  "jsc_android_timezone_validate.patch"
)

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
