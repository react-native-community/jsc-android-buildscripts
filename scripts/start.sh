#!/bin/bash -ex

ROOTDIR=$PWD
VERSION_NAME=$($ROOTDIR/scripts/version.sh)

# $ROOTDIR/scripts/compile/all.sh

cd $ROOTDIR/lib
# if ${npm_package_config_i18n}
# then
#   ./gradlew clean libIntl:installArchives
# else
#   ./gradlew clean lib:installArchives
# fi

cd $ROOTDIR/lib/android
zip -r "../../dist/$VERSION_NAME.zip" "."

cd $ROOTDIR
git add -A
git commit -m "compiled $VERSION_NAME"

printf "\n\n\n\n\n\t\t\tCompiled Version: ${VERSION_NAME}\n\n\n\n\n\n"
say -v Carmit "I am not slacking off, my code is compiling."
say -v Carmit "${VERSION_NAME}"
