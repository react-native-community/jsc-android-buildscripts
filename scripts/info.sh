#!/bin/bash -e

ROOTDIR=$PWD
REVISION=$(svn info --show-item last-changed-revision "https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}")
INFO=$(svn info "https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}")
CONFIG=$(node -e "console.log(require('./package.json').config)")

SIZE=$(du -ah $ROOTDIR/build/compiled || echo "-")

printf "\n\n\n\n\n\t\t\tRevision: \x1B[32m$REVISION\x1B[0m\n\n\n"
printf "Config:\n$CONFIG\n\n"
printf "Info:\n$INFO\n\n"
printf "Size:\t$SIZE\n\n"
