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
# This script performs some common post-installation tasks for Debian. The main
# thing is to install the full x64 and x86 development environments and some
# common libraries. Tailor it to your needs. 
# ------------------------------------------------------------------------------
#
# Add VirtualBox shared folder to fstab, and mount it
cat <<EOF | sudo tee -a /etc/fstab > /dev/null
# VirtualBox shared folder
${USER} /mnt/${USER} vboxsf auto,rw,uid=$(id -u),gid=$(id -g) 0 0
EOF
sudo mount /mnt/${USER}

# Install build tools for x86 and x64
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y build-essential g++-multilib libusb-1.0-0-dev libreadline6-dev
sudo apt-get install -y libc6-dev-i386 libusb-1.0-0:i386 libreadline6:i386
cd /usr/lib/i386-linux-gnu/
sudo ln -s /lib/i386-linux-gnu/libusb-1.0.so.0 libusb-1.0.so
sudo ln -s /lib/i386-linux-gnu/libreadline.so.6 libreadline.so
