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
mkdir -p msys
mkdir -p msys/bin
mkdir -p msys/etc
mkdir -p msys/var/tmp
mkdir -p libs
mkdir -p apps
mkdir -p 3rd
mkdir -p scripts

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
rm -rf unpack
mkdir -p unpack
cd unpack/
unzip ../7za920.zip
for i in ../*.tar.lzma*; do tar --lzma -xf $i; done
cd ..
cat > ../msys/etc/profile <<EOF
if [ \${PROCESSOR_ARCHITEW6432:-null} = null ]; then
  # We're not in WOW64 so this is probably an x86 system
  export HOSTTYPE=x86
else
  # We're in WOW64 so this is probably an x86_64 system
  export HOSTTYPE=x64
fi
export PATH="/bin:.:\$PATH"
export PS1="\${USERNAME}@\${HOSTNAME}\$ "
EOF
cat > ../scripts/getvim.sh <<EOF
mkdir vim
cd vim
wget -q 'http://prdownloads.sourceforge.net/mingw/vim-7.3-2-msys-1.0.16-bin.tar.lzma?download'
7za.exe x -so vim-7.3-2-msys-1.0.16-bin.tar.lzma | tar xf -
mv bin/vim.exe /bin/
cd ..
rm -rf vim
EOF
chmod +x ../scripts/getvim.sh

export MAIN_README=$(mktemp --tmpdir=/var/tmp)

cat > $MAIN_README <<EOF
MAKESTUFF BUILD INFRASTRUCTURE

Most of the software on makestuff.eu uses this cross-platform build
infrastructure to abstract the details of compilation away from individual
projects to a central location.

There are four subdirectories here:

  libs - Libraries (.dll, .lib, .so, .dylib, .a etc).
  apps - Executables (.exe etc).
  3rd - Third-party libraries, etc.
  scripts - A few useful scripts.

Once you've installed the infrastructure in a convenient location of your choice
(e.g NATIVE_LOC), you can then fetch and build some application code from
GitHub:

  cd BASH_LOC/apps
  ../scripts/msget.sh makestuff/lsep
  cd lsep
  make deps

This will fetch the master branch of the lsep source code and build it,
transitively fetching dependencies as necessary. You can build libraries in a
similar way:

  cd BASH_LOC/libs
  ../scripts/msget.sh makestuff/libbuffer
  cd libbuffer
  make deps

If instead of the master branch you wish to fetch the source code for the
development branch, you can do that like this:

  ../scripts/msget.sh makestuff/libbuffer/dev

Or if you want the source code for a specific release:

  ../scripts/msget.sh makestuff/libbuffer/20130701

If you fetch a different branch or a specific release, the dependencies will be
correctly matched when you do make deps.

If you have git installed and wish to fetch the code for editing, you can do so
using the msgit.sh script:

  ../scripts/msgit.sh makestuff/libbuffer

This time it defaults to fetching the dev branch. If you want a different
branch, you can specify it as before:

  ../scripts/msgit.sh makestuff/libbuffer/master

Cloning from GitHub in this way will only give you one local branch; to get
another of the remote branches you can do it with:

  git checkout -b dev origin/dev

Have fun!
EOF

cat $MAIN_README | sed 's/NATIVE_LOC/C:\/makestuff/g;s/BASH_LOC/\/c\/makestuff/g' >> ../README.txt

cat >> ../README.txt <<EOF


WINDOWS MSYS ENVIRONMENT

The msys directory contains a minimal build system comprising MinGW binaries
downloaded from SourceForge, where you can get copies of the software licenses
and source code for these binaries. I have packaged it like this purely for your
convenience; you can construct your own copy of this by running the
make-build-infra.sh script on a GNU-like machine:

  https://github.com/makestuff/scripts/raw/master/make-build-infra.sh

To use, you should unpack the "makestuff" directory to C:/ and make a desktop
shortcut to the shell interpreter:

  C:\makestuff\msys\bin\sh.exe --login

In practice you will want to edit C:\makestuff\msys\etc\profile to setup a
suitable environment. You will also want to run the Visual Studio command-line
script to pick up the MSVC compiler and tools:

  %comspec% /k "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86 && set MACHINE=x86 && C:\makestuff\msys\bin\sh.exe --login

Obviously the name and exact path to vcvarsall.bat will differ from system to
system. You can usually pass a parameter to the vcvarsall.bat script to choose
a 64-bit compiler:

  %comspec% /k "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86_amd64 && set MACHINE=x64 && C:\makestuff\msys\bin\sh.exe --login

You can find details here:

  http://msdn.microsoft.com/en-us/library/vstudio/x4d2c09s.aspx

If you need a text editor, you can run /c/makestuff/scripts/getvim.sh.
EOF
unix2dos ../README.txt

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
cp ../msg*.sh scripts/
cd ..

# Zip Windows build and publish it:
zip -r makestuff-windows-${DATE}.zip makestuff
mv makestuff-windows-${DATE}.zip ${PUBDIR}

# Remove Windows-only msys dir, zip remainder and publish:
rm -rf makestuff/msys
rm -f makestuff/README.txt
cat $MAIN_README | sed 's/NATIVE_LOC/\$HOME\/makestuff/g;s/BASH_LOC/\$HOME\/makestuff/g' > makestuff/README
rm -f makestuff/scripts/getvim.sh
tar zcf makestuff-lindar-${DATE}.tar.gz makestuff
mv makestuff-lindar-${DATE}.tar.gz ${PUBDIR}
rm -rf makestuff
rm -f $MAIN_README
