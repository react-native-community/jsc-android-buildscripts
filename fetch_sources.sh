#!/bin/bash -e

# set version for gradle artifacts
VERSION_NAME=`echo ${npm_package_config_webkitGTK} | sed -e "s/\./_/g"`
sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=${VERSION_NAME}/" lib/lib/gradle.properties lib/libIntl/gradle.properties
rm lib/lib/gradle.properties.bak lib/libIntl/gradle.properties.bak

# download sources
TARGET_DIR=target
SVN_DIR="releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}"

mkdir -p $TARGET_DIR/webkit
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/Source $TARGET_DIR/webkit/Source
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/Tools $TARGET_DIR/webkit/Tools
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/CMakeLists.txt $TARGET_DIR/webkit/CMakeLists.txt

mkdir -p $TARGET_DIR/icu
# This is for the latest release for the latest android from https://android.googlesource.com/platform/external/icu/
curl "https://android.googlesource.com/platform/external/icu/+archive/android-${npm_package_config_android_icu}/icu4c.tar.gz" | tar xzf - -C $TARGET_DIR/icu
