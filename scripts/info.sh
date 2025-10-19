#!/bin/bash -e

ROOTDIR=$PWD

WEBKIT_REPO="${npm_package_config_bunWebKitRepo:-https://github.com/oven-sh/WebKit.git}"
WEBKIT_COMMIT="${npm_package_config_bunWebKitCommit}"

export REVISION=$(node -e "console.log(require('./package.json').version.split('.')[0])")
CONFIG=$(node -e "console.log(JSON.stringify(require('$ROOTDIR/package.json').config, null, 2))")

if [[ -n "$WEBKIT_COMMIT" ]]; then
  WEBKIT_URL="https://github.com/oven-sh/WebKit/tree/${WEBKIT_COMMIT}"
  RAW_URL="https://raw.githubusercontent.com/oven-sh/WebKit/${WEBKIT_COMMIT}"
  APPLE_VERSION=$(curl -fsSL "${RAW_URL}/Configurations/Version.xcconfig" | grep 'MAJOR_VERSION\s=\|MINOR_VERSION\s=\|TINY_VERSION\s=\|MICRO_VERSION\s=\|NANO_VERSION\s=' || true)
else
  WEBKIT_URL="$WEBKIT_REPO"
  APPLE_VERSION="unknown"
fi

if [ -d "$INSTALL_DIR_I18N_false" ]; then
  SIZE=$(du -ah "$INSTALL_DIR_I18N_false")
else
  SIZE="0"
fi

printf "\n\n\n\n\n\t\t\tRevision: \x1B[32m$REVISION\x1B[0m\n\n\n"
printf "WebKit repository:\n%s @ %s\n\n" "$WEBKIT_REPO" "${WEBKIT_COMMIT:-unknown}"
printf "Upstream URL:\n%s\n\n" "$WEBKIT_URL"
printf "Config:\n%s\n\n" "$CONFIG"
printf "AppleWebKit version components:\n%s\n\n" "$APPLE_VERSION"
printf "Size:\n$SIZE\n\n"
