#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/setup.sh
if [ -n "${SETUP}" ]
then
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE_INSTALL=1; shift;;
        *)  break;;
    esac
    shift
done

MSG_ABORT="Aborting installation."

if [ ! -d ${INSTALL_DIR} ]
then   
    echo "Install directory (${INSTALL_DIR}) doesn't exists."
    mkdir -p ${INSTALL_DIR} || {
        echo "Unable to create install directory (${INSTALL_DIR}). ${MSG_ABORT}">&2
        exit 1
    }
elif [ ! -w ${INSTALL_DIR} ]
then   
    echo "Cannot write in ${INSTALL_DIR}: Permission denied. ${MSG_ABORT}" >&2
    exit 1
fi

INSTALL_DIR_INODES=$(find ${INSTALL_DIR} -mindepth 1 -maxdepth 1  -not -name "newinstall-qserv-*.sh" -not -name ".qserv_install_scripts")
if [ -n "${INSTALL_DIR_INODES}" ]; then
    if [ ${FORCE_INSTALL} ]; then
        echo "Erasing existing Qserv install"
        chmod -R u+rwx ${INSTALL_DIR}/*
        find ${INSTALL_DIR}/* -not -name "newinstall-qserv-*.sh" -not -name ".qserv_install_scripts" -delete
    else
        echo "Install directory (${INSTALL_DIR}) has to be empty. ${MSG_ABORT}" >&2
        echo "Please remove :" >&2
        echo "$INSTALL_DIR_INODES" >&2
        exit 2
    fi 
fi

eups_install

# install git latest version
source "${INSTALL_DIR}/eups/bin/setups.sh"

# If you don't have git > v1.8.4, do:
eups distrib install git --repository=${EUPS_PKGROOT_LSST}
setup git ||
{
    echo "Unable to install git. ${MSG_ABORT}" >&2
    exit 2
}


# Try to use system python, if a compatible version is available
CHECK_SYSTEM_PYTHON='import sys; exit(1) if sys.version_info < (2, 4) or sys.version_info > (2, 8) else exit(0)'
python -c "$CHECK_SYSTEM_PYTHON"
retcode=$?
if [ $retcode == 0 ]
then 
    echo "Detected Qserv-compatible sytem python version; will use it."
    EUPS_PYTHON=$EUPS_PATH/$(eups flavor)/python/system
    mkdir -p $EUPS_PYTHON/ups
    eups declare python system -r $EUPS_PYTHON -m none
    cat > $EUPS_PATH/site/manifest.remap <<-EOF
python  system
EOF
else
    echo "Qserv depends on system python 2.6 or 2.7. Please install it. ${MSG_ABORT}" >&2
    exit 2  
fi    

# Try to use system numpy, if a compatible version is available
CHECK_NUMPY='import numpy'
python -c "$CHECK_NUMPY" && {
    if [ $(eups list python --version) == 'system' ]
    then    
        SYSPATH=`python -c "import inspect,sys, numpy; modulepath=inspect.getfile(numpy); paths=[path for path in sys.path if modulepath.startswith(path)]; print sorted(paths)[-1]"`
        [ -d ${SYSPATH} ] || {
            echo "Unable to detect system numpy PYTHONPATH. ${MSG_ABORT}" >&2
            exit 2
        }
        echo "Detected Qserv-compatible sytem numpy version in ${SYSPATH}; will use it."
        EUPS_NUMPY=$EUPS_PATH/$(eups flavor)/numpy/system
        mkdir -p $EUPS_NUMPY/ups
        EUPS_NUMPY_TABLE=${EUPS_NUMPY}/ups/numpy.table
        cat > ${EUPS_NUMPY_TABLE} <<-EOF
setupRequired(python)
envPrepend(PYTHONPATH, $SYSPATH)
EOF
        eups declare numpy system -r ${EUPS_NUMPY} -m ${EUPS_NUMPY_TABLE}
        cat >> $EUPS_PATH/site/manifest.remap <<-EOF
numpy  system
EOF
    else        
        echo "Unable to detect system numpy library. ${MSG_ABORT}" >&2
        exit 2
    fi
}

#
# Try to use system java, if a compatible version is available
#
if check_java_version 1.6
then
    PRODUCT=java
    echo "Detected Qserv-compatible sytem java version; will use it."
    EUPS_PRODUCT_PATH=${EUPS_PATH}/$(eups flavor)/${PRODUCT}/system
    mkdir -p $EUPS_PRODUCT_PATH/ups
    eups declare ${PRODUCT} system -r $EUPS_PRODUCT_PATH -m none
    cat >> $EUPS_PATH/site/manifest.remap <<-EOF
${PRODUCT}  system
EOF
else
    echo "Qserv depends on system ${PRODUCT} 1.6. Please install it. ${MSG_ABORT}" >&2
    exit 2
fi

eups distrib install sconsUtils --repository="${EUPS_PKGROOT_LSST}" &&
setup sconsUtils ||
{
    echo "Unable to install sconsUtils. ${MSG_ABORT}" >&2
    exit 2
}

echo "Installing Qserv in ${INSTALL_DIR}"
time eups distrib install qserv && 
setup qserv || {
    echo "Failed to install Qserv"
    exit 2
}

SETUP_SCRIPT=${INSTALL_DIR}/setup-qserv.sh
cat > ${SETUP_SCRIPT} <<-EOF
export EUPS_PKGROOT=${EUPS_PKGROOT}
export EUPS_PKGROOT_LSST=${EUPS_PKGROOT_LSST}
source ${INSTALL_DIR}/eups/bin/setups.sh
setup qserv
EOF

echo "Installation complete"
echo "Now type "
echo 
echo "  source ${INSTALL_DIR}/setup-qserv.sh"
echo 
echo "to enable Qserv and its dependencies"
echo "and"
echo 
echo "  cd $QSERV_DIR/admin"
echo "  scons"
echo 
echo "to configure a Qserv mono-node instance"
echo "and"
echo 
echo "  qserv-start.sh"
echo "  qserv-testdata.py"
echo 
echo "to launch integration tests"
