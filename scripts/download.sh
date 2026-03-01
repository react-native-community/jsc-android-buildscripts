#!/bin/bash -e

ROOTDIR=$PWD

# download sources
rm -rf "$ROOTDIR/build"
TARGET_DIR="$ROOTDIR/build/download"
WEBKIT_DIR="$TARGET_DIR/webkit"

REPO_URL="${npm_package_config_bunWebKitRepo:-https://github.com/oven-sh/WebKit.git}"
WEBKIT_COMMIT="${npm_package_config_bunWebKitCommit}"
ICU_RELEASE="${npm_package_config_icuRelease}"
ICU_ARCHIVE="${npm_package_config_icuArchive}"

if [[ -z "$WEBKIT_COMMIT" ]]; then
  echo "Missing bunWebKitCommit in package.json config." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
mkdir -p "$WEBKIT_DIR"

pushd "$WEBKIT_DIR" > /dev/null
git init
git remote add origin "$REPO_URL"
git fetch --depth 1 origin "$WEBKIT_COMMIT"
git checkout --detach FETCH_HEAD
popd > /dev/null

mkdir -p "$TARGET_DIR/icu"
if [[ -n "$ICU_RELEASE" ]]; then
  if [[ -z "$ICU_ARCHIVE" ]]; then
    echo "Missing icuArchive for release ${ICU_RELEASE}" >&2
    exit 1
  fi
  curl -L "https://github.com/unicode-org/icu/releases/download/${ICU_RELEASE}/${ICU_ARCHIVE}" | tar xzf - --strip-components=1 -C "$TARGET_DIR/icu"
else
  echo "No ICU release configured for download." >&2
  exit 1
fi
