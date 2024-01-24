#!/bin/sh

# Copyright (c) 2023 Triad National Security, LLC
# SPDX-License-Identifier: BSD 3-Clause

sudo apt-get -y update
sudo apt-get -y upgrade
# Dependencies taken from parthenon build instructions
sudo apt-get -y install build-essential cmake \
                        libhdf5-openmpi-dev \
                        python3 python3-pip

sudo -E python3 -m pip install numpy

# Hack to clone the submodule with https instead of ssh
# In the event the submodules ever change to use ssh
git config --global url.https://github.com/.insteadOf git@github.com:
git clone --recursive https://github.com/parthenon-hpc-lab/parthenon.git

cd parthenon

# yoinked from lanl.github.io/benchmarks

mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="-fno-math-errno -march=native" \
      -DPARTHENON_DISABLE_HDF5=ON  \
      -DREGRESSION_GOLD_STANDARD_SYNC=OFF  \
      -DCMAKE_BUILD_TYPE=Release \
      ..

# Change QEMU builder memory limits to build faster
make -j
