#!/bin/bash

if [[ "${JSC_TOOLCHAIN_CONFIGURED:-0}" == "1" ]]; then
  return
fi
export JSC_TOOLCHAIN_CONFIGURED=1

if ! [[ $ROOTDIR ]]; then
  ROOTDIR=$(pwd)
fi

ANDROID_NDK_PATH="${ANDROID_NDK:-}"
SOURCE_PROPERTIES_PATH=""
if [[ -n "$ANDROID_NDK_PATH" && -f "$ANDROID_NDK_PATH/source.properties" ]]; then
  SOURCE_PROPERTIES_PATH="$ANDROID_NDK_PATH/source.properties"
fi

VARIANT_OVERRIDE="${JSC_NDK_VARIANT:-}"

variant_output=$(node - "$ROOTDIR" "$VARIANT_OVERRIDE" "$SOURCE_PROPERTIES_PATH" <<'NODE'
const fs = require('fs');
const path = require('path');

const rootDir = process.argv[2];
const variantOverride = process.argv[3] || '';
const sourcePropertiesPath = process.argv[4];

const pkg = require(path.join(rootDir, 'package.json'));
const variants = Array.isArray(pkg.config?.ndkVariants)
  ? pkg.config.ndkVariants
  : [];

const defaultVariant =
  variants.find((variant) => variant && variant.default) ||
  variants[0] ||
  null;

let revision = '';
if (sourcePropertiesPath && fs.existsSync(sourcePropertiesPath)) {
  const contents = fs.readFileSync(sourcePropertiesPath, 'utf8');
  const match = contents.match(/Pkg\.Revision\s*=\s*([^\s]+)/);
  if (match) {
    revision = match[1].trim();
  }
}

const matchRevision = (variant) => {
  if (!revision || !variant) {
    return false;
  }
  const prefixes = Array.isArray(variant.pkgRevisionPrefixes)
    ? variant.pkgRevisionPrefixes
    : [];
  return prefixes.some((prefix) => revision.startsWith(prefix));
};

let variant =
  (variantOverride && variants.find((variant) => variant.id === variantOverride)) ||
  variants.find(matchRevision) ||
  defaultVariant ||
  null;

const emit = (line) => {
  if (line !== undefined && line !== null) {
    console.log(line);
  }
};

if (revision) {
  emit(`JSC_TOOLCHAIN_NDK_REVISION=${revision}`);
}

if (defaultVariant) {
  emit(`JSC_TOOLCHAIN_DEFAULT_VARIANT=${defaultVariant.id}`);
  if (defaultVariant.npmPackage) {
    emit(`JSC_TOOLCHAIN_DEFAULT_NPM_PACKAGE=${defaultVariant.npmPackage}`);
  }
  if (defaultVariant.distDir) {
    emit(`JSC_TOOLCHAIN_DEFAULT_DIST_DIR=${defaultVariant.distDir}`);
  }
  if (defaultVariant.distUnstrippedDir) {
    emit(`JSC_TOOLCHAIN_DEFAULT_DIST_UNSTRIPPED_DIR=${defaultVariant.distUnstrippedDir}`);
  }
}

if (variant) {
  emit(`JSC_TOOLCHAIN_VARIANT=${variant.id}`);
  if (variant.npmPackage) {
    emit(`JSC_TOOLCHAIN_VARIANT_PACKAGE=${variant.npmPackage}`);
  }
  const buildSuffix =
    variant.hasOwnProperty('buildSuffix')
      ? String(variant.buildSuffix ?? '')
      : defaultVariant && variant.id === defaultVariant.id
        ? ''
        : variant.id;
  emit(`JSC_TOOLCHAIN_VARIANT_BUILD_SUFFIX=${buildSuffix}`);
  if (variant.distDir) {
    emit(`JSC_TOOLCHAIN_VARIANT_DIST_DIR=${variant.distDir}`);
  }
  if (variant.distUnstrippedDir) {
    emit(`JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR=${variant.distUnstrippedDir}`);
  }
  emit(
    `JSC_TOOLCHAIN_VARIANT_DISABLE_LOOP_VECTORIZATION=${variant.disableLoopVectorization ? 1 : 0}`,
  );
  emit(
    `JSC_TOOLCHAIN_VARIANT_ENABLE_THIN_LTO=${variant.enableThinLTO === false ? 0 : 1}`,
  );
} else {
  emit('JSC_TOOLCHAIN_VARIANT=');
  emit('JSC_TOOLCHAIN_VARIANT_BUILD_SUFFIX=');
  emit('JSC_TOOLCHAIN_VARIANT_DIST_DIR=');
  emit('JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR=');
  emit('JSC_TOOLCHAIN_VARIANT_DISABLE_LOOP_VECTORIZATION=0');
  emit('JSC_TOOLCHAIN_VARIANT_ENABLE_THIN_LTO=1');
}
NODE
)
ret=$?
if [[ $ret -ne 0 ]]; then
  echo "Failed to read NDK variant configuration" 1>&2
  exit $ret
fi

eval "$variant_output"

if [[ -z "$JSC_TOOLCHAIN_VARIANT" ]]; then
  if [[ -n "$JSC_TOOLCHAIN_DEFAULT_VARIANT" ]]; then
    export JSC_TOOLCHAIN_VARIANT="$JSC_TOOLCHAIN_DEFAULT_VARIANT"
  else
    export JSC_TOOLCHAIN_VARIANT=unknown
  fi
fi

if [[ -n "$JSC_TOOLCHAIN_VARIANT_BUILD_SUFFIX" && -z "$JSC_BUILD_VARIANT" ]]; then
  if [[ -n "$JSC_TOOLCHAIN_VARIANT_BUILD_SUFFIX" ]]; then
    export JSC_BUILD_VARIANT="$JSC_TOOLCHAIN_VARIANT_BUILD_SUFFIX"
  fi
fi

if [[ -n "$JSC_TOOLCHAIN_VARIANT_DIST_DIR" && -z "$JSC_DIST_DIR" ]]; then
  if [[ "$JSC_TOOLCHAIN_VARIANT_DIST_DIR" = /* ]]; then
    export JSC_DIST_DIR="$JSC_TOOLCHAIN_VARIANT_DIST_DIR"
  else
    export JSC_DIST_DIR="$ROOTDIR/$JSC_TOOLCHAIN_VARIANT_DIST_DIR"
  fi
fi

if [[ -n "$JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR" && -z "$JSC_DIST_UNSTRIPPED_DIR" ]]; then
  if [[ "$JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR" = /* ]]; then
    export JSC_DIST_UNSTRIPPED_DIR="$JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR"
  else
    export JSC_DIST_UNSTRIPPED_DIR="$ROOTDIR/$JSC_TOOLCHAIN_VARIANT_DIST_UNSTRIPPED_DIR"
  fi
fi

if [[ -z "$JSC_TOOLCHAIN_CXX_STANDARD" ]]; then
  export JSC_TOOLCHAIN_CXX_STANDARD=23
fi

if [[ -z "$JSC_CCACHE_BIN" && "${JSC_TOOLCHAIN_DISABLE_CCACHE:-0}" != "1" ]]; then
  if command -v ccache >/dev/null 2>&1; then
    export JSC_CCACHE_BIN=$(command -v ccache)
    export CCACHE_DIR=${CCACHE_DIR:-$HOME/.cache/ccache}
    export CCACHE_BASEDIR=${CCACHE_BASEDIR:-$ROOTDIR}
    export CCACHE_COMPRESS=${CCACHE_COMPRESS:-1}
    export CCACHE_CPP2=${CCACHE_CPP2:-yes}
    export ANDROID_NDK_CCACHE="$JSC_CCACHE_BIN"
  fi
fi

if [[ "${JSC_TOOLCHAIN_VARIANT_ENABLE_THIN_LTO:-1}" == "1" ]]; then
  export JSC_TOOLCHAIN_LTO_FLAG="-flto=thin"
else
  export JSC_TOOLCHAIN_LTO_FLAG=""
fi

if [[ "${JSC_TOOLCHAIN_VARIANT_DISABLE_LOOP_VECTORIZATION:-0}" == "1" ]]; then
  export JSC_TOOLCHAIN_RELEASE_CFLAGS="-fno-vectorize -fno-slp-vectorize"
else
  export JSC_TOOLCHAIN_RELEASE_CFLAGS="-Wno-pass-failed"
fi

if [[ -n "$JSC_TOOLCHAIN_LTO_FLAG" ]]; then
  export JSC_TOOLCHAIN_RELEASE_LDFLAGS="$JSC_TOOLCHAIN_LTO_FLAG"
else
  export JSC_TOOLCHAIN_RELEASE_LDFLAGS=""
fi

if [[ "${JSC_TOOLCHAIN_SUPPRESS_LOG:-0}" != "1" ]]; then
  if [[ -n "$JSC_TOOLCHAIN_NDK_REVISION" ]]; then
    echo "Detected Android NDK revision ${JSC_TOOLCHAIN_NDK_REVISION} (variant ${JSC_TOOLCHAIN_VARIANT})"
  else
    echo "Using Android NDK variant ${JSC_TOOLCHAIN_VARIANT}"
  fi
fi
