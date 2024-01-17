#!/bin/sh

# Copyright (c) 2023 Triad National Security, LLC
# SPDX-License-Identifier: BSD 3-Clause

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential cmake \
                        openmpi-bin libopenmpi-dev \
                        git

git clone -b ats5 https://github.com/lanl/branson.git

cd branson

# yoinked from lanl.github.io/benchmarks
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../src
make -j
