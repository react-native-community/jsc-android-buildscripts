#!/bin/bash -ex

ROOTDIR=$PWD
REVISION=$($ROOTDIR/scripts/revision.sh)
CONFIG=$(node -e "console.log(require('./package.json').config)")

# compile
rm -rf $ROOTDIR/build/compiled
$ROOTDIR/scripts/compile/all.sh

# create aar
cd $ROOTDIR/lib
./gradlew clean createAAR --project-prop revision="$REVISION" --project-prop i18n="$npm_package_config_i18n"
cd $ROOTDIR

printf "\n\n\n\n\n\t\t\tCompiled Version: \x1B[32m$REVISION\x1B[0m\n\n\n\nconfig:\n$CONFIG\n\n\n\n"
say -v Carmit "I am not slacking off, my code's compiling."
