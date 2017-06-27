#!/bin/bash

ROOTDIR=`pwd`

cd $ROOTDIR/target

patch -p0 < $ROOTDIR/patches/jsc.patch
