#/bin/bash

function usage {
	echo "Synopsis: $0 [-b <branch>] [<meta>] <proj>" 1>&2
	echo "  <branch> - the git branch to fetch (default: \"master\")" 1>&2
	echo "  <user>   - the github.com user (default: \"makestuff\")" 1>&2
	echo "  <repo>   - the github.com repository (required)" 1>&2
	exit 1
}

BRANCH=master
while [ "${1:0:1}" == "-" ]; do
	OPT=${1:1}
	case $OPT in
		b) shift; BRANCH=$1; shift;;
		*) usage;;
	esac
done

if [ $# == 1 ]; then
	USER=makestuff
	REPO=$1
elif [ $# == 2 ]; then
	USER=$1
	REPO=$2
else
	usage
fi

if [ -e ${REPO} ]; then
	echo "Repository \"${REPO}\" already exists" 1>&2
	exit 1
fi

wget --no-check-certificate -q -O ${USER}-${REPO}-${BRANCH}.tgz https://github.com/${USER}/${REPO}/archive/${BRANCH}.tar.gz
if [ "$?" != 0 ]; then
	echo "Fetch of \"${USER}/${REPO}/${BRANCH}\" failed. Are you sure it exists?" 1>&2
	rm -f ${USER}-${REPO}-${BRANCH}.tgz
	exit 1
fi

tar zxf ${USER}-${REPO}-${BRANCH}.tgz
mv ${REPO}-${BRANCH} ${REPO}
echo ${BRANCH} > ${REPO}/.branch
rm -f ${USER}-${REPO}-${BRANCH}.tgz

echo "Successfully unpacked \"${USER}/${REPO}/${BRANCH}\" into \"${REPO}\". Have fun!"
