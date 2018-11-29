#!/usr/bin/env bash

set -x
set -e

export ROOTDIR="$( cd "$(dirname "$0"/..)" ; pwd -P )"
export PATCHDIR=$ROOTDIR/build/patching
export DOWNLOADDIR=$ROOTDIR/build/download
export TARGETDIR=$ROOTDIR/build/target

if [[ "$1" = "jsc" ]]
then
    export PATCH_JSC=true
elif [[ "$1" = "inspector" ]]
then
    export PATCH_INSPECTOR=true
fi

if [[ "$2" = "apply" ]]
then
    rm -rf $TARGETDIR $PATCHDIR
    cp -R $DOWNLOADDIR $PATCHDIR

    printf "\n\n\t\t===================== patch jsc =====================\n\n"
    patch -d $PATCHDIR -p1 < $ROOTDIR/patches/jsc.patch
    find $PATCHDIR -iname '*.orig' -exec rm {} +
    if [[ $PATCH_INSPECTOR ]]
    then
        printf "\n\n\t\t=================== patch inspector ===================\n\n"
        patch -d $PATCHDIR -p1 < $ROOTDIR/patches/jsc_inspector.patch
        find $PATCHDIR -iname '*.orig' -exec rm {} +
    fi
elif [[ "$2" = "gen" ]]
then
    rm -rf $TARGETDIR $ROOTDIR/build/target-org
    if [[ $PATCH_JSC ]]
    then
        cp -r $PATCHDIR $TARGETDIR
        cp -r $DOWNLOADDIR $ROOTDIR/build/target-org
        cp $ROOTDIR/patches/jsc.patch $ROOTDIR/patches/jsc.patch.old
        printf "\n\n\t\t=================== generate jsc patch ===================\n\n"
        cd $ROOTDIR/build
        set +e
        diff -Naur target-org/webkit target/webkit > $ROOTDIR/patches/jsc.patch
    elif [[ $PATCH_INSPECTOR ]]
    then
        cp -r $PATCHDIR $TARGETDIR
        cp -r $DOWNLOADDIR $ROOTDIR/build/target-org
        cp $ROOTDIR/patches/jsc_inspector.patch $ROOTDIR/patches/jsc_inspector.patch.old
        patch -d $ROOTDIR/build/target-org -p1 < $ROOTDIR/patches/jsc.patch
        find $ROOTDIR/build/target-org -iname '*.orig' -exec rm {} +
        printf "\n\n\t\t=================== generate inspector patch ===================\n\n"
        cd $ROOTDIR/build
        diff -Naur --new-file target-org/webkit target/webkit > $ROOTDIR/patches/jsc_inspector.patch
    fi
fi

printf "finish\n"
