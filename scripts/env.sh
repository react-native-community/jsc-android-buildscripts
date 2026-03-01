#!/bin/bash -e

export ROOTDIR=$PWD

BUILD_VARIANT_SUFFIX=""
if [[ -n "$JSC_BUILD_VARIANT" ]]; then
  BUILD_VARIANT_SUFFIX="-$JSC_BUILD_VARIANT"
fi

# Intermediated build target dir
export TARGETDIR=${TARGETDIR:-$ROOTDIR/build/target${BUILD_VARIANT_SUFFIX}}

# JSC shared library install dir
export INSTALL_DIR=${INSTALL_DIR:-$ROOTDIR/build/compiled${BUILD_VARIANT_SUFFIX}}

# JSC unstripped shared library install dir
export INSTALL_UNSTRIPPED_DIR=${INSTALL_UNSTRIPPED_DIR:-$ROOTDIR/build/compiled.unstripped${BUILD_VARIANT_SUFFIX}}

# CPP runtime shared library install dir
export INSTALL_CPPRUNTIME_DIR=${INSTALL_CPPRUNTIME_DIR:-$ROOTDIR/build/cppruntime${BUILD_VARIANT_SUFFIX}}

# Install dir for i18n build variants
export INSTALL_DIR_I18N_true=$INSTALL_DIR/intl
export INSTALL_DIR_I18N_false=$INSTALL_DIR/nointl
export INSTALL_UNSTRIPPED_DIR_I18N_true=$INSTALL_UNSTRIPPED_DIR/intl
export INSTALL_UNSTRIPPED_DIR_I18N_false=$INSTALL_UNSTRIPPED_DIR/nointl
