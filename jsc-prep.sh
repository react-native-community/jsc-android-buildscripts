#!/bin/bash

ROOTDIR=`pwd`

cd $ROOTDIR/target/webkit/Source

patch -p0 < $ROOTDIR/patches/jsc.patch
patch -p0 < $ROOTDIR/patches/wtf.patch
patch -p0 < $ROOTDIR/patches/jsc_cmake.patch