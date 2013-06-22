#/bin/bash

USER=makestuff
BRANCH=master

function usage {
	echo "Synopsis: $0 [-b <branch>] [<meta>] <proj>" 1>&2
	echo "  <branch> - the git branch to fetch (default: \"${BRANCH}\")" 1>&2
	echo "  <user>   - the github.com user (default: \"${USER}\")" 1>&2
	echo "  <repo>   - the github.com repository (required)" 1>&2
	exit 1
}

while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1}
	case $OPT in
		b) shift; BRANCH=$1; shift;;
		*) usage;;
	esac
done

if [ $# == 1 ]; then
	REPO=$1
else
	usage
fi

if [ -e ${REPO} ]; then
	echo "Repository \"${REPO}\" already exists" 1>&2
	exit 1
fi

echo "Fetching \"${USER}/${REPO}/${BRANCH}\"..."
wget --no-check-certificate -q -O ${USER}-${REPO}-${BRANCH}.tgz https://github.com/${USER}/${REPO}/archive/${BRANCH}.tar.gz
if [ "$?" != 0 ]; then
	echo "Fetch of \"${USER}/${REPO}/${BRANCH}\" failed. Are you sure it exists?" 1>&2
	rm -f ${USER}-${REPO}-${BRANCH}.tgz
	exit 1
fi

echo "Uncompressing \"${USER}/${REPO}/${BRANCH}\" into \"${REPO}\" directory..."
tar zxf ${USER}-${REPO}-${BRANCH}.tgz
mv ${REPO}-${BRANCH} ${REPO}
echo ${BRANCH} > ${REPO}/.branch
rm -f ${USER}-${REPO}-${BRANCH}.tgz

TOPDIR=$(dirname $(dirname $0))
if [ -e ${TOPDIR}/common ]; then
	if [ -e ${TOPDIR}/common/.branch ]; then
		COMMON_BRANCH=$(cat ${TOPDIR}/common/.branch)
	else
		COMMON_BRANCH=master
	fi
	if [ "${COMMON_BRANCH}" != "${BRANCH}" ]; then
		echo
		echo "ERROR: A \"${TOPDIR}/common\" directory exists, but it's on the ${COMMON_BRANCH} branch. You" 2>&1
		echo "       should not try to mix different versions together; they must be" 2>&1
		echo "       consistent!" 2>&1
		exit 1
	fi
else
	echo "Fetching \"${USER}/common/${BRANCH}\"..."
	wget --no-check-certificate -q -O ${USER}-common-${BRANCH}.tgz https://github.com/${USER}/common/archive/${BRANCH}.tar.gz
	if [ "$?" != 0 ]; then
		echo "Fetch of \"${USER}/common/${BRANCH}\" failed. Are you sure it exists?" 1>&2
		rm -f ${USER}-common-${BRANCH}.tgz
		exit 1
	fi
	echo "Uncompressing \"${USER}/common/${BRANCH}\" into \"${TOPDIR}/common\" directory..."
	tar zxf ${USER}-common-${BRANCH}.tgz
	echo ${BRANCH} > common-${BRANCH}/.branch
	mv common-${BRANCH} ${TOPDIR}/common
	rm -f ${USER}-common-${BRANCH}.tgz
fi
