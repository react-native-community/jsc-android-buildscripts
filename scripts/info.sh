#!/bin/bash -e

URL="https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}"
ROOTDIR=$PWD

export REVISION=$(svn info --show-item last-changed-revision "${URL}")

INFO=$(svn info "${URL}")
CONFIG=$(node -e "console.log(require('$ROOTDIR/package.json').config)")
APPLE_VERSION=$(svn cat "${URL}/Source/WebCore/Configurations/Version.xcconfig" | grep 'MAJOR_VERSION\s=\|MINOR_VERSION\s=\|TINY_VERSION\s=\|MICRO_VERSION\s=\|NANO_VERSION\s=')

if [ -d "$ROOTDIR/build/compiled" ]; then
  SIZE=$(du -ah $ROOTDIR/build/compiled)
else
  SIZE="0"
fi

printf "\n\n\n\n\n\t\t\tRevision: \x1B[32m$REVISION\x1B[0m\n\n\n"
printf "Config:\n$CONFIG\n\n"
printf "Info:\n$INFO\n\n"
printf "AppleWebkit:\n$APPLE_VERSION\n\n"
printf "Size:\n$SIZE\n\n"
