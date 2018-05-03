#!/bin/bash -e

ROOTDIR=`pwd`

patch -p0 < $ROOTDIR/patches/jsc.patch
