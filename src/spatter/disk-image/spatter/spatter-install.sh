#!/bin/sh

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential cmake \
                        openmpi-bin libopenmpi-dev \
                        python3 git-lfs

# Unfortunately need to set proxy here too until
# cloud-init adds global proxy config to user-data
if [ ! -z "$PROXY" ]; then
    git config --global http.proxy "$PROXY"
fi
# Hack to clone the submodule with https instead of ssh
git config --global url.https://github.com/.insteadOf git@github.com:
git clone --recursive https://github.com/lanl/spatter.git

cd spatter

# yoinked from spatter/scripts/setup.sh
git lfs pull

find ./patterns/flag -iname '*.tar.gz' -exec tar -xvzf {} \;
find ./patterns/xrage -iname '*.tar.gz' -exec tar -xvzf {} \;

python3 scripts/split.py

mv spatter.json patterns/xrage/asteroid/spatter.json
for i in {1..9}
do
    mv spatter${i}.json patterns/xrage/asteroid/spatter${i}.json
done

cd spatter

# yoinked from spatter README
cmake -DBACKEND=serial -DCOMPILER=gnu -B build_serial_gnu -S .
cd build_serial_gnu
make

cd ..

cmake -DBACKEND=openmp -DCOMPILER=gnu -DUSE_MPI=1 -B build_omp_mpi_gnu -S .
cd build_omp_mpi_gnu
make
