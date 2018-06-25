#!/bin/bash -e

# download sources
rm -rf $PWD/build
TARGET_DIR=$PWD/build/download
SVN_URL="releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}"

mkdir -p $TARGET_DIR/webkit
svn export https://svn.webkit.org/repository/webkit/$SVN_URL/Source $TARGET_DIR/webkit/Source
svn export https://svn.webkit.org/repository/webkit/$SVN_URL/Tools $TARGET_DIR/webkit/Tools
svn export https://svn.webkit.org/repository/webkit/$SVN_URL/CMakeLists.txt $TARGET_DIR/webkit/CMakeLists.txt

mkdir -p $TARGET_DIR/icu
curl "https://android.googlesource.com/platform/external/icu/+archive/android-${npm_package_config_androidICU}/icu4c.tar.gz" | tar xzf - -C $TARGET_DIR/icu
