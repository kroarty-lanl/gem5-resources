---
title: Parthenon-VIBE
tags:
    - x86
    - fullsystem
permalink: resources/parthenon-vibe
shortdoc: >
    Disk image and a gem5 configuration script to run [Spatter](https://github.com/hpcgarage/spatter/tree/main) with LANL patterns.
license: BSD-3-Clause
---

This document provides instructions to create a disk image needed to run parthenon-VIBE with gem5

The Parthenon-VIBE benchmark solves the Vector Inviscid Burgers’ Equation on a block-AMR mesh.
This benchmark is configured to use three levels of mesh resolution and mesh blocks of size 16^3.
This AMR configuration is meant to mimic applications which require high resolution, the ability to capture sharp and dynamic interfaces, while balancing global memory footprint and the overhead of “ghost” cells. [1](https://lanl.github.io/benchmarks/03_vibe/vibe.html)


We assume the following directory structure while following the instructions in this README file:

```
parthenon-vibe/
    ├── disk-image
    │   ├── build.sh                            # The script for downloading packer and building the disk image
    │   ├── shared                              # Auxiliary files for disk creation
    │   │   ├── meta-data
    │   │   ├── serial-getty@.service
    │   │   └── user-data                       # If behind a proxy, set it in this file
    │   ├── parthenon-vibe
    │   │   ├── gem5-init.sh                    # Executes a user-provided script in simulated guest
    │   │   ├── m5-download.sh                  # Script to build m5 and download the m5ops headers
    │   │   ├── m5-setup.sh                     # Misc setup to boot faster and set up m5
    │   │   ├── parthenon-vibe-install.sh       # Script to build parthenon-vibe
    │   │   └── parthenon-vibe.json             # Packer script to build the disk image
    │   └── parthenon-vibe-image                # Autogenerated directory, contains the disk image after building
    ├── LICENSE                                 # LANL license
    └── README.md                               # This README file
```

## Disk Image

#### NOTE: If you are behind a proxy, set it in `disk-image/shared/user-data` before building

Assuming that you are in the `src/parthenon-vibe/` directory (the directory containing this README), execute the following:

```sh
cd disk-image
./build.sh          # the script downloading packer binary and building the disk image
```

Once this process succeeds, the created disk image can be found on `parthenon-vibe/parthenon-vibe-image/parthenon-vibe`.

## Using the disk image

Parthenon is built in `/home/gem5/parthenon/build`

The Parthenon-VIBE (burgers) benchmark binary is located at
```
/home/gem5/parthenon/build/benchmarks/burgers/burgers-benchmark
```

## Simulating Parthenon-VIBE using the sample script

This uses the sample KVM config that's provided in another git repo (link to be placed)

Assumes directory structure:
```
.
├── gem5
├── gem5-resources
└── gem5-configs
```

To build gem5:

```sh
#If you haven't downloaded gem5 yet
git clone https://github.com/gem5/gem5.git

cd gem5
# Note: The build can sometimes fail if you allocate a large -j while not
# having enough memory
scons -j$(nproc) build/X86/gem5.opt

To run a simple Parthenon example (Calculate pi):

```
gem5/build/X86/gem5.opt \
    gem5-configs/simple-kvm-config.py \
    --image gem5-resources/src/parthenon-vibe/disk-image/parthenon-vibe/parthenon-vibe
    --command="cd /home/gem5/parthenon/tst/regression; ./run_test.py --test_dir test_suites/calculate_pi --driver ../../build/example/calculate_pi/pi-example --driver_input test_suites/calculate_pi/parthinput.regression"
```

To find inputs for the burgers benchmarks follow instructions listed [here](https://lanl.github.io/benchmarks/03_vibe/vibe.html)

## Using Charliecloud with gem5

LANL uses Charliecloud containers as a way to run applications in a container while
minimizing the permissions the user gets when running in a container.

To build a Charliecloud image to use gem5 with: (Dockerfile will be in same repo as the configs)
```sh
module load charliecloud
ch-image build -t gem5 --force fakeroot .
# Image is now stored as a tarball so you don't have to build it every time
ch-convert gem5 gem5.tar.gz

# To "activate" the image:
ch-convert gem5.tar.gz /var/tmp/gem5
```

Building gem5 using charliecloud:

```sh
ch-run -w -b </home/or/scratch/dir>:</home/or/scratch/dir> -c </path/to/gem5/dir> /var/tmp/gem5 -- \
    scons -j$(nproc) build/X86/gem5.opt
```

Running Spatter example using charliecloud:
```sh
# /path/to/above/dir is the path to the directory with the structure listed above
ch-run -w -b </home/or/scratch/dir>:</home/or/scratch/dir> -c </path/to/above/dir> /var/tmp/gem5 -- \
    gem5/build/X86/gem5.opt \
        gem5-configs/simple-kvm-config.py \
        --image gem5-resources/src/parthenon-vibe/disk-image/parthenon-vibe/parthenon-vibe
        --command="cd /home/gem5/parthenon/tst/regression; ./run_test.py --test_dir test_suites/calculate_pi --driver ../../build/example/calculate_pi/pi-example --driver_input test_suites/calculate_pi/parthinput.regression"
```