#!/bin/sh

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential scons

if [ ! -z "$PROXY" ]; then
    git config --global http.proxy "$PROXY"
fi

git clone --no-checkout https://github.com/gem5/gem5.git
cd gem5
git sparse-checkout init --cone
git sparse-checkout set util/m5 include
git checkout stable
cd util/m5
scons build/x86/out/m5
cp build/x86/out/m5 /home/gem5/
