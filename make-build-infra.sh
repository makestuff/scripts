#!/bin/sh
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
export DATE=$(date +%Y%m%d)
#export PUBDIR=/mnt/ukfsn/bin/
export PUBDIR=$HOME
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
wget 'http://prdownloads.sourceforge.net/mingw/dash-0.5.5.1_2-1-msys-1.0.13-bin.tar.lzma?download'
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
if [ -z "\${MACHINE}" ]; then
  echo "You need to set MACHINE to x86 or x64; see C:\\\\makestuff\\\\README.txt"
fi
export PATH="/bin:.:\$PATH"
export PS1="\${USERNAME}@\${HOSTNAME}\$ "
export HOME=/c/makestuff
alias e="\${HOME}/msys/emacs-24.3/bin/emacs -nw"
alias h="history"
EOF

cat > ../scripts/getvim.sh <<EOF
#!/bin/sh
mkdir vim
cd vim
wget 'http://prdownloads.sourceforge.net/mingw/vim-7.3-2-msys-1.0.16-bin.tar.lzma?download'
7za.exe x -so vim-7.3-2-msys-1.0.16-bin.tar.lzma | tar xf -
mv bin/vim.exe /bin/
cd ..
rm -rf vim
EOF

cat > ../scripts/getemacs.sh <<EOFGETEMACS
#!/bin/sh
mkdir emacs
cd emacs
wget 'http://mirror.switch.ch/ftp/mirror/gnu/windows/emacs/emacs-24.3-bin-i386.zip'
unzip emacs-24.3-bin-i386.zip
mv emacs-24.3 \${HOME}/msys/
cd ..
rm -rf emacs
cat > ~/.emacs <<EOF
(set-language-environment "UTF-8")
(setq-default indent-tabs-mode 0);
(setq default-truncate-lines 1)
(setq truncate-partial-width-windows default-truncate-lines)
(setq backup-inhibited 1)
(setq inhibit-startup-message 1)

(line-number-mode 1)
(column-number-mode 1)
(auto-save-mode 0)
(menu-bar-mode 0)

(setq default-tab-width 4)
(setq backup-inhibited 1)
(setq compile-command (concat "make -C " (getenv "PWD")))
(setq compilation-read-command nil)
(setq compilation-ask-about-save nil)
(setq compilation-scroll-output 1)

(global-set-key [f5] "\C-xo")
(global-set-key [f9] 'buffer-menu)
(global-set-key [f12] 'compile)

(defun my-c-mode-common-hook ()
  (c-set-style "bsd")
  (setq c-basic-offset 4)
  (c-set-offset 'arglist-close '(c-lineup-close-paren))
)
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(add-hook 'vhdl-mode-hook
  '(lambda ()
    (setq indent-tabs-mode 1)
    (setq vhdl-self-insert-comments nil)
    (setq comment-column 0)
    (setq end-comment-column 120)
  )
)
(defvar vhdl-basic-offset 4)

(setq interprogram-cut-function nil)
(setq interprogram-paste-function nil)
(defun paste-from-pasteboard()
  (interactive)
  (and mark-active (filter-buffer-substring (region-beginning) (region-end) t))
  (insert (ns-get-pasteboard))
)
(defun copy-to-pasteboard(p1 p2)
  (interactive "r*")
  (ns-set-pasteboard (buffer-substring p1 p2))
  (message "Copied selection to pasteboard")
)
(defun cut-to-pasteboard(p1 p2)
  (interactive "r*")
  (ns-set-pasteboard (filter-buffer-substring p1 p2 t))
)
(global-set-key (kbd "s-v") 'paste-from-pasteboard)
(global-set-key (kbd "s-c") 'copy-to-pasteboard)
(global-set-key (kbd "s-x") 'cut-to-pasteboard)
EOF
EOFGETEMACS

export MAIN_README=$(mktemp --tmpdir=/var/tmp)

cat > $MAIN_README <<EOF
------------------------ MAKESTUFF BUILD INFRASTRUCTURE ------------------------

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

  cd UNIX_LOC/apps
  ../scripts/msget.sh makestuff/lsep
  cd lsep
  make deps

This will fetch the master branch of the lsep source code and build it,
transitively fetching dependencies as necessary. You can build libraries in a
similar way:

  cd UNIX_LOC/libs
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

cat $MAIN_README | sed 's/NATIVE_LOC/C:\/makestuff/g;s/UNIX_LOC/\/c\/makestuff/g' >> ../README.txt

cat >> ../README.txt <<EOF


--------------------------- WINDOWS MSYS UNIX TOOLS ----------------------------

The msys directory contains a minimal set of build tools comprising MinGW/MSYS
binaries downloaded from SourceForge, where you can get copies of the software
licenses and source code for these binaries. I have packaged it like this purely
for your convenience; you can construct your own copy of this by running the
make-build-infra.sh script on a GNU-like machine:

  https://github.com/makestuff/scripts/raw/master/make-build-infra.sh
EOF
unix2dos ../README.txt

cat > ../INSTALL.txt <<EOFINSTALL
--------------------------- WINDOWS MSYS ENVIRONMENT ---------------------------

To use, you should unpack the "makestuff" directory to C:/ and make a desktop
shortcut using this line as a target:

  C:\makestuff\msys\bin\bash.exe --login

That will give you a shell prompt, but on its own it's not much use. What you do
next depends on what you want to use the build infrastructure for.

If you need a text editor, you can run $HOME/scripts/getvim.sh or
$HOME/scripts/getemacs.sh to download and install Vim or Emacs.


---------------- COMPILING C/C++ CODE (VISUAL STUDIO INSTALLED) ----------------

If you already have Microsoft Visual Studio installed (2010, 2012 or 2013,
Express editions are fine), you first need to find the location of the
vcvarsall.bat script. Find the shortcut called "Visual Studio Command Prompt" in
your start menu, right-click it and select Properties, then make a note of the
full path to vcvarsall.bat, in the "Target" box.

If your OS is a 32-bit (x86) version of Windows, you will only be able to make
32-bit executables. Create a desktop shortcut with this line for a target,
replacing the the path to vcvarsall.bat with the actual path on your system:

  %comspec% /c "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86 && set MACHINE=x86 && C:\makestuff\msys\bin\bash.exe --login

You may find it helpful to enter "C:\makestuff" in the "Start in" box, and to
check "QuickEdit mode" on the "Options" pane.

If your OS is a 64-bit (x64) version of Windows, you can go ahead and create a
32-bit (x86) command-prompt as above, but you'll also have the additional option
of creating a 64-bit (x64) command-prompt, or both. Again, make a shortcut
using this line for a target, replacing the path to vcvarsall.bat with the
actual path from your system:

  %comspec% /c "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86_amd64 && set MACHINE=x64 && C:\makestuff\msys\bin\bash.exe --login

Again, select start in "C:\makestuff", and enable QuickEdit.


-------------- COMPILING C/C++ CODE (VISUAL STUDIO NOT INSTALLED) --------------

Visual Studio is a large download. Since all we need is the command-line tools,
you can get away with just the Windows SDK, which is rather smaller:

http://www.microsoft.com/en-gb/download/details.aspx?id=8279

Unfortunately 7.1 is the last version of the SDK which does include the command-
line tools, so if you need more recent tools you must install the full Visual
Studio.

After the install completes, find the shortcut in your start menu named "Windows
SDK 7.1 Command Prompt", right-click it and select "Properties", then make a
note of the full path to SetEnv.cmd, in the "Target" box.

If your OS is a 32-bit (x86) version of Windows, you will only be able to make
32-bit executables. Create a desktop shortcut with this line for a target,
replacing the the path to SetEnv.bat with the actual path on your system:

  %comspec% /c "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.bat" /x86 && set MACHINE=x86 && C:\makestuff\msys\bin\bash.exe --login

You may find it helpful to enter "C:\makestuff" in the "Start in" box, and to
check "QuickEdit mode" on the "Options" pane.

If your OS is a 64-bit (x64) version of Windows, you can go ahead and create a
32-bit (x86) command-prompt as above, but you'll also have the additional option
of creating a 64-bit (x64) command-prompt, or both. Again, make a shortcut
using this line for a target, replacing the path to SetEnv.bat with the actual
path from your system:

  %comspec% /c "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.bat" /x64 && set MACHINE=x64 && C:\makestuff\msys\bin\bash.exe --login

Again, select start in "C:\makestuff", and enable QuickEdit.


---------------- SYNTHESIZING HDL CODE WITH XILINX ISE WEBPACK -----------------

Compiling HDL code (VHDL or Verilog) into an FPGA config file involves several
steps which are usually performed by the ISE GUI. But getting repeatable builds
from many HDL files with slightly different config parameters for different FPGA
boards is error-prone. To get more repeatable builds, you can use a small Python
script called hdlmake.py (replace 20130812 here with the branch/tag of your
choice):

  cd $HOME
  scripts/msget.sh makestuff/hdlmake/20130812

To run it you'll need to install Python 2.7:

  http://www.python.org/ftp/python/2.7.5/python-2.7.5.msi (for 32-bit)
  http://www.python.org/ftp/python/2.7.5/python-2.7.5.amd64.msi (for 64-bit)

When you install, choose "install for me only". Next, install PyYAML:

  http://pyyaml.org/download/pyyaml/PyYAML-3.10.win32-py2.7.exe 

Finally, add the Xilinx tools and Python itself to the system PATH. You can
easily do this by adding some commands to /etc/profile, which is executed when
you open a new console window. Copy and paste these commands into a console
window, replacing "14.4" with the actual version of Xilinx ISE you have:

cat >> /etc/profile <<EOF
ISE_VER=14.4
if [ "\\\${HOSTTYPE}" = "x86" ]; then
  export PATH=\\\${PATH}:/c/Xilinx/\\\${ISE_VER}/ISE_DS/ISE/bin/nt
else
  export PATH=\\\${PATH}:/c/Xilinx/\\\${ISE_VER}/ISE_DS/ISE/bin/nt64 
fi
export PATH=\\\${PATH}:/c/Python27
export PATH=\\\${PATH}:\\\${HOME}/hdlmake/bin
EOF

Once installed, you can now use hdlmake.py to fetch and build HDL code, e.g:

  cd $HOME/hdlmake/apps
  hdlmake.py -g makestuff/swled
  cd makestuff/swled/cksum/vhdl
  hdlmake.py -t ../../templates/fx2all/vhdl -b nexys2-1200 -p fpga prom

That fetches and builds the VHDL version of the FPGALink cksum example,
generating a pair of .xsvf files suitable for loading into the FPGA and flash
PROM of a Nexys2 (1200K version) board.
EOFINSTALL
unix2dos ../INSTALL.txt

cp unpack/7za.exe ../msys/bin/
cp unpack/bin/bunzip2.exe ../msys/bin/
cp unpack/bin/bzip2.exe ../msys/bin/
cp unpack/bin/cat.exe ../msys/bin/
cp unpack/bin/cmp.exe ../msys/bin/
cp unpack/bin/cp.exe ../msys/bin/
cp unpack/bin/date.exe ../msys/bin/
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
cp unpack/bin/dash.exe ../msys/bin/sh.exe
cp unpack/bin/bash.exe ../msys/bin/
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
cat $MAIN_README | sed 's/NATIVE_LOC/\$HOME\/makestuff/g;s/UNIX_LOC/\$HOME\/makestuff/g' > makestuff/README
rm -f makestuff/scripts/getvim.sh
tar zcf makestuff-lindar-${DATE}.tar.gz makestuff
mv makestuff-lindar-${DATE}.tar.gz ${PUBDIR}
rm -rf makestuff
rm -f $MAIN_README
