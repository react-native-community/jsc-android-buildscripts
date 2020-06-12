#!/bin/bash -e

URL="https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}"
ROOTDIR=$PWD

INFO=$(svn info "${URL}")
export REVISION=$(LANG=en svn info "${URL}" | sed -n 's/^Last Changed Rev: //p')
CONFIG=$(node -e "console.log(require('$ROOTDIR/package.json').config)")
APPLE_VERSION=$(svn cat "${URL}/Source/WebCore/Configurations/Version.xcconfig" | grep 'MAJOR_VERSION\s=\|MINOR_VERSION\s=\|TINY_VERSION\s=\|MICRO_VERSION\s=\|NANO_VERSION\s=')

if [ -d "$INSTALL_DIR_I18N_false" ]; then
  SIZE=$(du -ah $INSTALL_DIR_I18N_false)
else
  SIZE="0"
fi

printf "\n\n\n\n\n\t\t\tRevision: \x1B[32m$REVISION\x1B[0m\n\n\n"
printf "Config:\n$CONFIG\n\n"
printf "Info:\n$INFO\n\n"
printf "AppleWebkit:\n$APPLE_VERSION\n\n"
printf "Size:\n$SIZE\n\n"
