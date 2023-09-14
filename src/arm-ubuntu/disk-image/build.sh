#!/bin/bash

# Copyright (c) 2022 The Regents of the University of California.
# SPDX-License-Identifier: BSD 3-Clause

# Downloading packer

PACKER_VERSION="1.8.0"

if [ ! -f ./packer ]; then
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip;
    unzip packer_${PACKER_VERSION}_linux_amd64.zip;
    rm packer_${PACKER_VERSION}_linux_amd64.zip;
fi

# Validating and executing packer

./packer validate arm-ubuntu/arm-ubuntu.json
./packer build arm-ubuntu/arm-ubuntu.json

exit
