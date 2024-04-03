#!/bin/bash

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential \
                        wget \
                        python3 gdb

wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.2.tar.bz2

tar xf openmpi-5.0.2.tar.bz2
cd openmpi-5.0.2

./configure  --enable-mpi-fortran=no CFLAGS="-mno-avx512f -mno-avx" CXXCFLAGS="-mno-avx512f -mno-avx" 2>&1 | tee config.out
make -j 4 all 2>&1 | tee make.out
sudo make install 2>&1 | tee install.out

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

cd ~/mpi-tests

mpicc send_recv.c -g -mno-avx512f -mno-avx -o send_recv_c
mpicc hello_mpi.c -g -mno-avx512f -mno-avx -o hello_mpi_c

#mpif90 send_recv.f90 -g -mno-avx -mno-avx512f -o send_recv_f90
#mpif90 hello_mpi.f90 -g -mno-avx -mno-avx512f -o hello_mpi_f90


mpirun -n 2 ./hello_mpi_c
mpirun -n 2 ./send_recv_c
