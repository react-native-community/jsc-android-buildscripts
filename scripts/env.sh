#!/bin/bash -e

export ROOTDIR=$PWD

# Intermediated build target dir
export TARGETDIR=$ROOTDIR/build/target

# JSC shared library install dir
export INSTALL_DIR=$ROOTDIR/build/compiled

# JSC unstripped shared library install dir
export INSTALL_UNSTRIPPED_DIR=$ROOTDIR/build/compiled.unstripped

# Install dir for i18n build variants
export INSTALL_DIR_I18N_true=$INSTALL_DIR/intl
export INSTALL_DIR_I18N_false=$INSTALL_DIR/nointl
export INSTALL_UNSTRIPPED_DIR_I18N_true=$INSTALL_UNSTRIPPED_DIR/intl
export INSTALL_UNSTRIPPED_DIR_I18N_false=$INSTALL_UNSTRIPPED_DIR/nointl
