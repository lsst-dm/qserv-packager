if [ -n "${QSERV_PKG_ROOT}" ]
then
  if [ -r ${QSERV_PKG_ROOT} ]
  then
    source ${QSERV_PKG_ROOT}/functions.sh
    echo "Setting up distribution environment"
    source ${QSERV_PKG_ROOT}/dist/env-dist.sh
  else
    echo "QSERV_PKG_ROOT=${QSERV_PKG_ROOT} is not set is not readable"
  fi
else
  echo "QSERV_PKG_ROOT is not set"
  SETUP_DIST=FAIL
fi

