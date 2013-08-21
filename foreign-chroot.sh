#!/bin/sh -x
#
# Copyright (C) 2013 Chris McClelland
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
# ------------------------------------------------------------------------------
# This script constructs three foreign-architecture chroot environments on a
# Debian host, for armel, armhf and powerpc. It creates a script qemu-chroot.sh
# which can be used to switch to the chroot, or execute a specific command in
# the chroot. For example, to build flcli for all three architectures:
#
#   qemu-chroot.sh armel make -C $HOME/makestuff/apps/flcli deps 
#   qemu-chroot.sh armhf make -C $HOME/makestuff/apps/flcli deps 
#   qemu-chroot.sh powerpc make -C $HOME/makestuff/apps/flcli deps 
#
# The armel and powerpc installations use the standard Debian packages for those
# architectures, but the armhf installation uses the Raspbian packages, which
# are built for armv6 and are therefore supported on more boards than the armv7a
# Debian armhf build.
#
# Identifying which chroot you're in can be tricky, so it's a good idea to add
# these lines to .bash_aliases, so it's always clear from your shell prompt
# where you are:
#
#   ABI=$(gcc -dumpmachine)
#   if [ "${ABI}" = "x86_64-linux-gnu" ]; then
#     export PS1="${USER}@x64\$ "
#   elif [ "${ABI}" = "arm-linux-gnueabihf" ]; then
#     export PS1="${USER}@armhf\$ "
#   elif [ "${ABI}" = "arm-linux-gnueabi" ]; then
#     export PS1="${USER}@armel\$ "
#   elif [ "${ABI}" = "powerpc-linux-gnu" ]; then
#     export PS1="${USER}@ppc\$ "
#   else
#     export PS1="${USER}@unknown\$ "
#   fi
#
# Be VERY careful when removing these chroots - the install process and the
# qemu-chroot.sh script both mount system directories and the home directories
# inside the chroots. If you find yourself typing "sudo rm -rf /var/qemu/armel",
# stop and think for a while; "mount | grep qemu" is your best friend.
# ------------------------------------------------------------------------------
#
build_qemu() {
  # Get dependencies
  sudo apt-get -y install pkg-config
  sudo apt-get -y install debootstrap
  sudo apt-get -y install zlib1g-dev
  sudo apt-get -y install libglib2.0-dev
  sudo apt-get -y install autoconf
  sudo apt-get -y install libtool

  # Fetch QEMU source and build it into a static binary
  QEMU_VER=1.6.0
  wget -q http://wiki.qemu-project.org/download/qemu-${QEMU_VER}.tar.bz2
  bunzip2 -c qemu-${QEMU_VER}.tar.bz2 | tar xf -
  cd qemu-${QEMU_VER}
  ./configure --disable-kvm --target-list=arm-linux-user,ppc-linux-user --static
  make
  sudo cp arm-linux-user/qemu-arm /usr/local/bin/qemu-arm-static
  sudo cp ppc-linux-user/qemu-ppc /usr/local/bin/qemu-ppc-static
  cd ..
  rm -rf qemu-${QEMU_VER}
}

gen_script() {
cat <<EOF | sudo tee /usr/local/bin/qemu-chroot.sh > /dev/null
#!/bin/sh

usage() {
  echo "Synopsis: qemu-chroot.sh <armel|armhf|powerpc> [<command to run in chroot>]"
  echo "  -r  retain root privileges inside chroot"
  exit 1
}

# Find out if we want to retain root privileges in the chroot
if [ "\$1" = "-r" ]; then
  SU=1
  shift
else
  SU=0
fi

# Get architecture to chroot
if [ "\$#" -lt "1" ]; then
  usage
fi
if [ "\$1" != "armel" -a "\$1" != "armhf" -a "\$1" != "powerpc" ]; then
  usage
fi
ARCH=\$1
shift

# Mount system stuff...
TARGET_PATH=/var/qemu/\${ARCH}
if [ ! -e /proc/sys/fs/binfmt_misc/arm ]; then
  echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-arm-static:' | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
fi
if [ ! -e /proc/sys/fs/binfmt_misc/ppc ]; then
  echo ':ppc:M::\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x14:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/local/bin/qemu-ppc-static:' | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
fi
if [ "\$(mount | grep -c "\${TARGET_PATH}/dev ")" -eq "0" ]; then
  echo "Mounting dev"
  sudo mount --bind /dev \${TARGET_PATH}/dev
fi
if [ "\$(mount | grep -c "\${TARGET_PATH}/dev/pts ")" -eq "0" ]; then
  echo "Mounting dev/pts"
  sudo mount --bind /dev/pts \${TARGET_PATH}/dev/pts
fi
if [ "\$(mount | grep -c "\${TARGET_PATH}/proc ")" -eq "0" ]; then
  echo "Mounting proc"
  sudo mount --bind /proc \${TARGET_PATH}/proc
fi
if [ "\$(mount | grep -c "\${TARGET_PATH}/sys ")" -eq "0" ]; then
  echo "Mounting sys"
  sudo mount --bind /sys \${TARGET_PATH}/sys
fi
if [ "\$(mount | grep -c "\${TARGET_PATH}/home ")" -eq "0" ]; then
  echo "Mounting home"
  sudo mount --bind /home \${TARGET_PATH}/home
fi

# If running Debian in a Virtual machine with shared folder in /mnt...
if [ -e /mnt/\${USER} -a "\$(mount | grep -c "\${TARGET_PATH}/mnt/\${USER} ")" -eq "0" ]; then
  echo "Mounting /mnt/\${USER}"
  sudo mkdir -p \${TARGET_PATH}/mnt/\${USER}
  sudo mount --bind /mnt/\${USER} \${TARGET_PATH}/mnt/\${USER}
fi

# Launch chroot...
if [ "\${SU}" -eq "1" ]; then
  sudo /usr/sbin/chroot \${TARGET_PATH} \$*
else
  if [ "\$#" -eq "0" ]; then
    sudo /usr/sbin/chroot \${TARGET_PATH} su - \${USER}
  else
    sudo /usr/sbin/chroot \${TARGET_PATH} su - \${USER} -c "\$*"
  fi
fi
EOF
sudo chmod +x /usr/local/bin/qemu-chroot.sh
}

create_chroot() {
  ARCH=$1
  URL=$2
  TARGET_PATH=/var/qemu/${ARCH}

  # Construct the chrooted Debian installation:
  sudo mkdir -p ${TARGET_PATH}
  sudo /usr/sbin/debootstrap --no-check-gpg --arch=${ARCH} --foreign --variant=minbase wheezy ${TARGET_PATH} ${URL}

  # Hard-link the QEMU static binaries into the chroot as well
  sudo mkdir -p ${TARGET_PATH}/usr/local/bin
  sudo ln /usr/local/bin/qemu-arm-static ${TARGET_PATH}/usr/local/bin/qemu-arm-static
  sudo ln /usr/local/bin/qemu-ppc-static ${TARGET_PATH}/usr/local/bin/qemu-ppc-static

  # Run the second stage installer
  qemu-chroot.sh -r ${ARCH} /debootstrap/debootstrap --second-stage

  # Generate sources.list
  echo "deb ${URL} wheezy main" | sudo tee ${TARGET_PATH}/etc/apt/sources.list > /dev/null

  # Copy post-install script into chroot and execute it
  sudo cp post-install.sh ${TARGET_PATH}/post-install.sh
  qemu-chroot.sh -r ${ARCH} /post-install.sh
}

# Make a "post-install" script to finalise the chroot install
PASSWD=$(grep -E ^$USER /etc/passwd)
SHADOW=$(sudo grep $USER /etc/shadow | perl -ane 'if(m/^(.*?):.*?:(.*?)$/){print"$1:x:$2";}')
cat > post-install.sh <<EOF
#!/bin/sh
apt-get update
apt-get -y install wget
apt-get -y install locales
apt-get -y install build-essential
apt-get -y install usbutils
apt-get -y install libusb-1.0-0-dev
apt-get -y install libreadline-dev
#apt-get -y install emacs23-nox
sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo ${PASSWD} >> /etc/passwd
echo ${SHADOW} >> /etc/shadow
EOF
chmod +x post-install.sh

# Register the QEMU static binaries with binfmt_misc
if [ ! -e /proc/sys/fs/binfmt_misc/arm ]; then
  echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-arm-static:' | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
fi
if [ ! -e /proc/sys/fs/binfmt_misc/ppc ]; then
  echo ':ppc:M::\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x14:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/local/bin/qemu-ppc-static:' | sudo tee /proc/sys/fs/binfmt_misc/register > /dev/null
fi

# Build everything...
build_qemu
gen_script
create_chroot armhf http://mirrordirector.raspbian.org/raspbian/
create_chroot armel http://ftp.uk.debian.org/debian/
create_chroot powerpc http://ftp.uk.debian.org/debian/
rm -f post-install.sh
