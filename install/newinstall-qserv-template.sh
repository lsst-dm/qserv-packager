#!/usr/bin/env bash
#
# Usage: sh newinstall.sh [package ...]
#
#  Set up some initial environment variables
#
# set -x

VERSIONTAG=%VERSIONTAG%
DISTSERVERNAME=%DISTSERVERNAME%

SHELL=/bin/bash
INSTALL_DIR=$PWD
export EUPS_PKGROOT="http://datasky.in2p3.fr/qserv/${DISTSERVERNAME}"

QSERV_PKG_REPO=git://dev.lsstcorp.org/contrib/qserv-packager
PKG_TAG=1.0

while [ $# -gt 0 ]; do
    case "$1" in 
        -H) INSTALL_DIR="$2"; shift;;
        -r) EUPS_PKGROOT="$2"; shift;;
        --force) FORCE_INSTALL="--force"; shift;;
        *)  break;;
    esac
    shift
done
cd $INSTALL_DIR

export PREFIX=.qserv_install_scripts
git archive --remote=${QSERV_PKG_REPO} --format=tar --prefix=${PREFIX}/ $PKG_TAG | tar xf - || {
    echo "Failed to download Qserv install scripts"
    exit 2
}

INSTALLSCRIPT_DIR=${INSTALL_DIR}/${PREFIX}

CFG_FILE="${INSTALLSCRIPT_DIR}/env.sh"
/bin/cat <<EOM >$CFG_FILE
export INSTALL_DIR=${INSTALL_DIR}
export VERSIONTAG=${VERSIONTAG}
export EUPS_PKGROOT=${EUPS_PKGROOT}
export EUPS_PKGROOT_LSST=http://sw.lsstcorp.org/eupspkg
export EUPS_GIT_CLONE_CMD="git clone https://github.com/RobertLuptonTheGood/eups.git"
export EUPS_GIT_CHECKOUT_CMD="git checkout 1.3.0"
EOM

# TODO rename QSERV_PKG_ROOT ?
export QSERV_PKG_ROOT=${INSTALLSCRIPT_DIR}
${INSTALLSCRIPT_DIR}/install/install.sh ${FORCE_INSTALL} || {
    echo "Failed to install Qserv using eups"
    exit 2
}
 
