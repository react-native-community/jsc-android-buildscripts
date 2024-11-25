#!/bin/bash -e

WEBKITGTK_VERSION="${npm_package_config_webkitGTK}"
# URL="https://github.com/WebKit/WebKit/tree/webkitgtk-${WEBKITGTK_VERSION}"
# FIXME: hardcoded branch because WebKitGTK 2.26 does not have tag
URL="https://github.com/WebKit/WebKit/tree/webkitgtk/2.26"
RAW_URL="https://raw.githubusercontent.com/WebKit/WebKit/refs/heads/webkitgtk/2.26"
ROOTDIR=$PWD

export REVISION=$(node -e "console.log(require('./package.json').version.split('.')[0])")
CONFIG=$(node -e "console.log(require('$ROOTDIR/package.json').config)")
APPLE_VERSION=$(wget -q -O - "${RAW_URL}/Source/WebCore/Configurations/Version.xcconfig" | grep 'MAJOR_VERSION\s=\|MINOR_VERSION\s=\|TINY_VERSION\s=\|MICRO_VERSION\s=\|NANO_VERSION\s=')

if [ -d "$INSTALL_DIR_I18N_false" ]; then
  SIZE=$(du -ah $INSTALL_DIR_I18N_false)
else
  SIZE="0"
fi

printf "\n\n\n\n\n\t\t\tRevision: \x1B[32m$REVISION\x1B[0m\n\n\n"
printf "WebKitGTK version:\n$WEBKITGTK_VERSION\n\n"
printf "Config:\n$CONFIG\n\n"
printf "AppleWebkit:\n$APPLE_VERSION\n\n"
printf "Size:\n$SIZE\n\n"
