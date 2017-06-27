#!/bin/bash

TARGET_DIR=target
SVN_DIR=releases/WebKitGTK/webkit-2.17.1

mkdir -p $TARGET_DIR/webkit
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/Source $TARGET_DIR/webkit/Source
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/Tools $TARGET_DIR/webkit/Tools
svn export https://svn.webkit.org/repository/webkit/$SVN_DIR/CMakeLists.txt $TARGET_DIR/webkit/CMakeLists.txt

mkdir -p $TARGET_DIR/icu
# This is for the latest release for the latest android from https://android.googlesource.com/platform/external/icu/
curl https://android.googlesource.com/platform/external/icu/+archive/android-7.1.2_r11/icu4c.tar.gz | tar xzf - -C $TARGET_DIR/icu
