BASEDIR=$(dirname $0)
source ${BASEDIR}/setup-dist.sh
if [ -n "${SETUP_DIST}" ]
then
    exit 1
fi


DEPS="expat libevent lua luaexpat luasocket luaxmlrpc mysql mysqlproxy
mysqlpython protobuf python qserv twisted virtualenv_python xrootd
zopeinterface kazoo zookeeper"

rm -rf ${DEPS_DIR}
mkdir ${DEPS_DIR}
cd ${DEPS_DIR}

for product in ${DEPS}
do
    echo "Cloning ${product}"
    git clone ssh://git@dev.lsstcorp.org/contrib/eupspkg/${product}
done

product=db
echo "Cloning ${product}"
git clone ssh://git@dev.lsstcorp.org/LSST/DMS/${product}

cd -
