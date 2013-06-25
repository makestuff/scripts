#
# Copyright (C) 2009-2012 Chris McClelland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#!/bin/bash

function usage {
	echo "Synopsis: $0 <user>/<repo>[/<branch>]" 1>&2
	echo "  <user>   - the github.com user (required)" 1>&2
	echo "  <repo>   - the github.com repository (required)" 1>&2
	echo "  <branch> - the git branch to fetch (default: \"${BRANCH}\")" 1>&2
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

OLDIFS=${IFS}
IFS='/'
TOKENS=($1)
IFS=${OLDIFS}
NUMTOK=${#TOKENS[@]}
if [ "$NUMTOK" == "2" ]; then
	USER=${TOKENS[0]}
	REPO=${TOKENS[1]}
	BRANCH=master
elif [ "$NUMTOK" == "3" ]; then
	USER=${TOKENS[0]}
	REPO=${TOKENS[1]}
	BRANCH=${TOKENS[2]}
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
	echo "Fetch of \"${USER}/${REPO}/${BRANCH}\" failed. Are you sure it exists on GitHub?" 1>&2
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
		COMMON_BRANCH=dev
	fi
	if [ "${COMMON_BRANCH}" != "${BRANCH}" ]; then
		echo
		echo "ERROR: A \"${TOPDIR}/common\" directory exists, but it's on the ${COMMON_BRANCH} branch. You" 2>&1
		echo "       should not try to mix different versions together; they must be" 2>&1
		echo "       consistent!" 2>&1
		exit 1
	fi
else
	echo "Fetching \"makestuff/common/${BRANCH}\"..."
	wget --no-check-certificate -q -O makestuff-common-${BRANCH}.tgz https://github.com/makestuff/common/archive/${BRANCH}.tar.gz
	if [ "$?" != 0 ]; then
		echo "Fetch of \"makestuff/common/${BRANCH}\" failed. Are you sure it exists?" 1>&2
		rm -f makestuff-common-${BRANCH}.tgz
		exit 1
	fi
	echo "Uncompressing \"makestuff/common/${BRANCH}\" into \"${TOPDIR}/common\" directory..."
	tar zxf makestuff-common-${BRANCH}.tgz
	echo ${BRANCH} > common-${BRANCH}/.branch
	mv common-${BRANCH} ${TOPDIR}/common
	rm -f makestuff-common-${BRANCH}.tgz
fi
