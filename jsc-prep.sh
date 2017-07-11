#!/bin/bash

ROOTDIR=`pwd`

patch -p0 < $ROOTDIR/patches/jsc.patch
