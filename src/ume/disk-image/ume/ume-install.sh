#!/bin/sh

# Copyright (c) 2020 The Regents of the University of California.
# SPDX-License-Identifier: BSD 3-Clause

# install build-essential (gcc and g++ included) and gfortran

#Compile NPB
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential scons git cmake \
                        libelf-dev python3 python3-venv \
                        pip catch2 gcc-12 g++-12

git clone https://github.com/lanl/UME.git

cd ume
mkdir -p build

cd build
CC=/usr/bin/gcc-12 CXX=/usr/bin/g++-12 cmake ..
CC=/usr/bin/gcc-12 CXX=/usr/bin/g++-12 make -j
