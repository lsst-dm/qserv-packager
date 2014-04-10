# used for both installation and package distribution :
export INSTALL_DIR=/opt/eupspkg-qserv
TICKET=DM-405
export VERSIONTAG=6.0.0rc1-${TICKET}
export DISTSERVERNAME=distserver-${TICKET}
export EUPS_PKGROOT="http://datasky.in2p3.fr/qserv/${DISTSERVERNAME}"
export EUPS_PKGROOT_LSST="http://sw.lsstcorp.org/eupspkg"
export EUPS_GIT_CLONE_CMD="git clone https://github.com/RobertLuptonTheGood/eups.git"
export EUPS_GIT_CHECKOUT_CMD="git checkout 1.3.0"


# used for package distribution only :
export REPOSITORY_BASE_CONTRIB=git://git.lsstcorp.org/contrib/eupspkg
export REPOSITORY_BASE_DMS=git://git.lsstcorp.org/LSST/DMS
export EUPSPKG_REPOSITORY_PATH='git://git.lsstcorp.org/contrib/eupspkg/$PRODUCT|git://git.lsstcorp.org/LSST/DMS/$PRODUCT'
export EUPSPKG_SOURCE=git
export LOCAL_PKGROOT=${INSTALL_DIR}/${DISTSERVERNAME}
export DEPS_DIR=${QSERV_PKG_ROOT}/dist/dependencies

export QSERV_REPO=git://dev.lsstcorp.org/LSST/DMS/qserv

export DATA_REPO=git://dev.lsstcorp.org/LSST/DMS/testdata/qservdata.git
export DATA_BRANCH=master
