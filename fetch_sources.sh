#!/bin/bash

TARGET_DIR=target
# This SVN revision number was determined by looking for the latest iOS release at https://trac.webkit.org/browser/webkit/releases/Apple
SVN_REV=216995
mkdir -p $TARGET_DIR/webkit
svn export -r $SVN_REV https://svn.webkit.org/repository/webkit/trunk/Source $TARGET_DIR/webkit/Source
svn export -r $SVN_REV https://svn.webkit.org/repository/webkit/trunk/Tools $TARGET_DIR/webkit/Tools
svn export -r $SVN_REV https://svn.webkit.org/repository/webkit/trunk/CMakeLists.txt $TARGET_DIR/webkit/CMakeLists.txt

# As the trunk for $SVN_REV differs from releases dir I'm replacing JSC and WTF with versions from releases dir
rm -rf $TARGET_DIR/webkit/Source/JavaScriptCore
svn export -r $SVN_REV https://svn.webkit.org/repository/webkit/releases/Apple/iOS%2010.3.2/JavaScriptCore $TARGET_DIR/webkit/Source/JavaScriptCore

rm -rf $TARGET_DIR/webkit/Source/WTF
svn export -r $SVN_REV https://svn.webkit.org/repository/webkit/releases/Apple/iOS%2010.3.2/WTF $TARGET_DIR/webkit/Source/WTF

mkdir -p $TARGET_DIR/icu
# This is for the latest release for the latest android from https://android.googlesource.com/platform/external/icu/
curl https://android.googlesource.com/platform/external/icu/+archive/android-7.1.2_r11/icu4c.tar.gz | tar xzf - -C $TARGET_DIR/icu
