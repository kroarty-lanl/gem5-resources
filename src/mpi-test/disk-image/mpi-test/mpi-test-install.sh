#!/bin/sh

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential \
                        openmpi-bin libopenmpi-dev \
                        python3 gdb

cd mpi-tests

mpicc send_recv.c -o send_recv_c
mpicc hello_mpi.c -g -o hello_mpi_c

mpif90 send_recv.f90 -o send_recv_f90
mpif90 hello_mpi.f90 -o hello_mpi_f90

