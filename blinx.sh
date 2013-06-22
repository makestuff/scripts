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
export DATE=$(date +%Y%m%d)
export PUBDIR=/mnt/ukfsn/bin/
mkdir makestuff
cd makestuff

# Make top-level msys directory containing minimal set of UNIX tools for Windows
mkdir -p all
cd all/
wget 'http://prdownloads.sourceforge.net/mingw/make-3.81-3-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/tar-1.23-1-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/gzip-1.3.12-2-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/grep-2.5.4-2-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/findutils-4.4.2-2-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/diffutils-2.8.7.20071206cvs-3-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/coreutils-5.97-3-msys-1.0.13-ext.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/coreutils-5.97-3-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/msysCORE-1.0.17-1-msys-1.0.17-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/termcap-0.20050421_1-2-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/bzip2-1.0.5-2-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/bash-3.1.17-4-msys-1.0.16-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/wget-1.12-1-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/patch-2.6.1-1-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/unzip-6.0-1-msys-1.0.13-bin.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/libiconv-1.13.1-2-msys-1.0.13-dll-2.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/libintl-0.17-2-msys-dll-8.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/libregex-1.20090805-2-msys-1.0.13-dll-1.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/libtermcap-0.20050421_1-2-msys-1.0.13-dll-0.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/libopenssl-1.0.0-1-msys-1.0.13-dll-100.tar.lzma?download'
wget 'http://prdownloads.sourceforge.net/mingw/sed-4.2.1-2-msys-1.0.13-bin.tar.lzma?download'
wget -O 7za920.zip 'http://prdownloads.sourceforge.net/sevenzip/7-Zip/9.20/7za920.zip?download'
rm -rf unpack ../msys
mkdir -p unpack
cd unpack/
unzip ../7za920.zip
for i in ../*.tar.lzma*; do tar --lzma -xf $i; done
cd ..
mkdir -p ../msys
mkdir -p ../msys/bin
mkdir -p ../msys/etc
mkdir -p ../msys/var/tmp
cat > ../msys/etc/profile <<EOF
# For Visual Studio Express 2010:
export MSVC=10.0
export MSWSDK=v7.0A
#export MSWSDK=v7.1
# For Visual Studio Express 2008:
#export MSVC=9.0
#export MSWSDK=v6.0A

export PATH="/bin:.:\$PATH"

if [ -e "/c/Program Files/Microsoft SDKs/Windows/\${MSWSDK}" ]; then
  export SDK_HOME="Program Files/Microsoft SDKs/Windows/\${MSWSDK}"
elif [ -e "/c/Program Files (x86)/Microsoft SDKs/Windows/\${MSWSDK}" ]; then
  export SDK_HOME="Program Files (x86)/Microsoft SDKs/Windows/\${MSWSDK}"
else
    echo "Cannot find Windows SDK version \${MSWSDK}."
    echo "Are you sure MSWSDK is set correctly in /etc/profile?"
    echo "These are the Windows SDKs you appear to have installed:"
    ls "/c/Program Files/Microsoft SDKs/Windows" 2> /dev/null
    ls "/c/Program Files (x86)/Microsoft SDKs/Windows" 2> /dev/null
fi

if [ -e "/c/Program Files/Microsoft Visual Studio \${MSVC}" ]; then
  export VS_HOME="Program Files/Microsoft Visual Studio \${MSVC}"
elif [ -e "/c/Program Files (x86)/Microsoft Visual Studio \${MSVC}" ]; then
  export VS_HOME="Program Files (x86)/Microsoft Visual Studio \${MSVC}"
else
  echo "Cannot find Visual Studio version \${MSVC}."
  echo "Have you set MSVC correctly in /etc/profile?"
  echo "These are the Visual Studio versions you appear to have installed:"
  ls "/c/Program Files" | grep "Microsoft Visual Studio" 2> /dev/null
  ls "/c/Program Files (x86)" | grep "Microsoft Visual Studio" 2> /dev/null
fi

if [ \${PROCESSOR_ARCHITEW6432:-null} = null ]; then
  # We're not in WOW64 so this is probably an x86 system
  export LIB="C:/\${VS_HOME}/VC/LIB;C:/\${SDK_HOME}/lib"
  export PATH="/c/\${VS_HOME}/VC/bin:\$PATH"
else
  # We're in WOW64 so this is probably an x86_64 system
  export LIB="C:/\${VS_HOME}/VC/LIB/amd64;C:/\${SDK_HOME}/lib/x64"
  export PATH="/c/\${VS_HOME}/VC/bin/amd64:\$PATH"
fi
export PATH="/c/\${SDK_HOME}/bin:\$PATH"
export PATH="/c/\${VS_HOME}/Common7/IDE:\$PATH"
export INCLUDE="C:/\${VS_HOME}/VC/INCLUDE;C:/\${SDK_HOME}/include"
export PS1="\${USERNAME}@\${HOSTNAME}\$ "
EOF
cat > ../msys/etc/profile.win8 <<EOF
# For Visual Studio Express 2012:
export MSVC=11.0
export MSWSDK=8.0

export PATH="/bin:.:\$PATH"

if [ -e "/c/Program Files/Windows Kits/\${MSWSDK}" ]; then
  export SDK_HOME="Program Files/Windows Kits/\${MSWSDK}"
elif [ -e "/c/Program Files (x86)/Windows Kits/\${MSWSDK}" ]; then
  export SDK_HOME="Program Files (x86)/Windows Kits/\${MSWSDK}"
else
    echo "Cannot find Windows SDK version \${MSWSDK}."
    echo "Are you sure MSWSDK is set correctly in /etc/profile?"
    echo "These are the Windows SDKs you appear to have installed:"
    ls "/c/Program Files/Windows Kits" 2> /dev/null
    ls "/c/Program Files (x86)/Windows Kits" 2> /dev/null
fi

if [ -e "/c/Program Files/Microsoft Visual Studio \${MSVC}" ]; then
  export VS_HOME="Program Files/Microsoft Visual Studio \${MSVC}"
elif [ -e "/c/Program Files (x86)/Microsoft Visual Studio \${MSVC}" ]; then
  export VS_HOME="Program Files (x86)/Microsoft Visual Studio \${MSVC}"
else
  echo "Cannot find Visual Studio version \${MSVC}."
  echo "Have you set MSVC correctly in /etc/profile?"
  echo "These are the Visual Studio versions you appear to have installed:"
  ls "/c/Program Files" | grep "Microsoft Visual Studio" 2> /dev/null
  ls "/c/Program Files (x86)" | grep "Microsoft Visual Studio" 2> /dev/null
fi

if [ \${PROCESSOR_ARCHITEW6432:-null} = null ]; then
  # We're not in WOW64 so this is probably an x86 system
  export LIB="C:/\${VS_HOME}/VC/LIB;C:/\${SDK_HOME}/lib/win8/um/x86"
  export PATH="/c/\${VS_HOME}/VC/bin:/c/\${SDK_HOME}/bin/x86:\$PATH"
else
  # We're in WOW64 so this is probably an x86_64 system
  export LIB="C:/\${VS_HOME}/VC/LIB/amd64;C:/\${SDK_HOME}/lib/win8/um/x64"
  export PATH="/c/\${VS_HOME}/VC/bin/x86_amd64:/c/\${SDK_HOME}/bin/x64:\$PATH"
fi
export PATH="/c/\${VS_HOME}/Common7/IDE:\$PATH"
export INCLUDE="C:/\${VS_HOME}/VC/INCLUDE;C:/\${SDK_HOME}/include/um;C:/\${SDK_HOME}/include/shared"
export PS1="\${USERNAME}@\${HOSTNAME}\$ "
EOF
cat > ../msys/bin/getvim.sh <<EOF
mkdir vim
cd vim
wget -q 'http://prdownloads.sourceforge.net/mingw/vim-7.3-2-msys-1.0.16-bin.tar.lzma?download'
7za.exe x -so vim-7.3-2-msys-1.0.16-bin.tar.lzma | tar xf -
mv bin/vim.exe /bin/
cd ..
rm -rf vim
EOF
chmod +x ../msys/bin/getvim.sh

cat > ../msys/README <<EOF
This directory contains a minimal build system comprising MinGW binaries downloaded from SourceForge,
where you can get copies of the software licenses and source code for these binaries. I have packaged
it like this purely for your convenience; you can construct your own copy of this by running the
makestuff.sh script on a GNU-like machine:

  https://github.com/makestuff/common/raw/master/makestuff.sh

To use, you should unpack the "makestuff" directory to C:/ and make a desktop shortcut to
C:\makestuff\msys\bin\sh.exe --login. The resulting command prompt assumes you have Microsoft Visual
Studio Express 2010 installed. If you want to use VS2008, edit /etc/profile.

If you're using Windows 8 and VS2012, you should replace /etc/profile with /etc/profile.win8:

mv /etc/profile /etc/profile.win7
mv /etc/profile.win8 /etc/profile

If you need a command-line editor, you can run getvim.sh.
EOF
cp unpack/7za.exe ../msys/bin/
cp unpack/bin/bunzip2.exe ../msys/bin/
cp unpack/bin/bzip2.exe ../msys/bin/
cp unpack/bin/cat.exe ../msys/bin/
cp unpack/bin/cmp.exe ../msys/bin/
cp unpack/bin/cp.exe ../msys/bin/
cp unpack/bin/dd.exe ../msys/bin/
cp unpack/bin/diff.exe ../msys/bin/
cp unpack/bin/dirname.exe ../msys/bin/
cp unpack/bin/echo.exe ../msys/bin/
cp unpack/bin/env.exe ../msys/bin/
cp unpack/bin/find.exe ../msys/bin/
cp unpack/bin/grep.exe ../msys/bin/
cp unpack/bin/gunzip ../msys/bin/
cp unpack/bin/gzip.exe ../msys/bin/
cp unpack/bin/ls.exe ../msys/bin/
cp unpack/bin/make.exe ../msys/bin/
cp unpack/bin/mkdir.exe ../msys/bin/
cp unpack/bin/msys-1.0.dll ../msys/bin/
cp unpack/bin/msys-crypto-1.0.0.dll ../msys/bin/
cp unpack/bin/msys-iconv-2.dll ../msys/bin/
cp unpack/bin/msys-intl-8.dll ../msys/bin/
cp unpack/bin/msys-regex-1.dll ../msys/bin/
cp unpack/bin/msys-ssl-1.0.0.dll ../msys/bin/
cp unpack/bin/msys-termcap-0.dll ../msys/bin/
cp unpack/bin/mv.exe ../msys/bin/
cp unpack/bin/patch.exe ../msys/bin/paatch.exe
cp unpack/bin/pwd.exe ../msys/bin/
cp unpack/bin/rm.exe ../msys/bin/
cp unpack/bin/sed.exe ../msys/bin/
cp unpack/bin/sh.exe ../msys/bin/
cp unpack/bin/tail.exe ../msys/bin/
cp unpack/bin/tar.exe ../msys/bin/
cp unpack/bin/tr.exe ../msys/bin/
cp unpack/bin/uname.exe ../msys/bin/
cp unpack/bin/unzip.exe ../msys/bin/
cp unpack/bin/wget.exe ../msys/bin/
cp unpack/etc/inputrc.default ../msys/etc/
cp unpack/etc/termcap ../msys/etc/
cp unpack/etc/wgetrc ../msys/etc/
cd ..
rm -rf all

# Make other top-level directories
mkdir libs
mkdir apps
mkdir 3rd
mkdir bin
cp ../msg*.sh bin/
cd ..

# Zip Windows build and publish it:
zip -r makestuff-win32-${DATE}.zip makestuff
mv makestuff-win32-${DATE}.zip ${PUBDIR}

# Remove Windows-only msys dir, zip remainder and publish:
rm -rf makestuff/msys
tar zcf makestuff-lindar-${DATE}.tar.gz makestuff
mv makestuff-lindar-${DATE}.tar.gz ${PUBDIR}
rm -rf makestuff
