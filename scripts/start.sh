#!/bin/bash -e

ROOTDIR=$PWD
REVISION=$(svn info --show-item last-changed-revision "https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}")

# compile
rm -rf $ROOTDIR/build/compiled
$ROOTDIR/scripts/compile/all.sh

# create aar
cd $ROOTDIR/lib
./gradlew clean createAAR --project-prop revision="$REVISION" --project-prop i18n="$npm_package_config_i18n"
cd $ROOTDIR

npm run info
echo "I am not slacking off, my code is compiling."
