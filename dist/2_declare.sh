BASEDIR=$(dirname $0)
source ${BASEDIR}/setup-dist.sh
if [ -n "${SETUP_DIST}" ]
then
    exit 1
fi

mkdir -p ${INSTALL_DIR} ||
{
	echo "Unable to create install dir : ${INSTALL_DIR}"
	exit 1
}

if [ ! -e "${INSTALL_DIR}/eups/bin/setups.sh" ]
then
    eups_install
else
    echo "INFO : using current eups version"
fi
. ${INSTALL_DIR}/eups/bin/setups.sh

# If you don't have python >= 2.7 with numpy >= 1.5.1 and
# matplotlib >=1.2.0, use Anaconda python distribution by installing
# it manually, or use the LSST-packaged one.
# eups distrib install anaconda
# setup anaconda

eups distrib install git --repository="http://sw.lsstcorp.org/eupspkg" &&
setup git


eups_undeclare_all
rm -rf ${LOCAL_PKGROOT}/*
eups declare python system -r none -m none
eups declare numpy system -r none -m none
eups_dist antlr 2.7.7 &&
eups_dist partition 1.0.1 ${REPOSITORY_BASE_DMS} &&
eups_dist mysql 5.1.65 &&
eups_dist xrootd qs5 &&
eups_dist lua 5.1.4 &&
eups_dist luasocket 2.0.2 &&
eups_dist expat 2.0.1 &&
eups_dist luaexpat 1.1 &&
eups_dist luaxmlrpc v1.2.1-2 &&
eups_dist libevent 2.0.16-stable &&
eups_dist mysqlproxy 0.8.2 &&
eups_dist virtualenv_python 1.10.1 &&
eups_dist mysqlpython 1.2.3 &&
eups_dist protobuf 2.4.1 &&
eups_dist zopeinterface 3.8.0 &&
eups_dist twisted 12.0.0 && 
eups_dist db 1.0 ${REPOSITORY_BASE_DMS} && 
eups_dist zookeeper 3.4.6 && 
eups_dist kazoo 2.0b1 || 
{
    echo "ERROR : unable to create all packages"
    exit 2
}

