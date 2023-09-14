---
title: Linux arm-ubuntu image
tags:
    - arm
    - fullsystem
layout: default
permalink: resources/arm-ubuntu
shortdoc: >
    Resources to build a generic arm-ubuntu disk image.
author: ["Hoa Nguyen", "Kaustav Goswami"]
---

This document provides instructions to create the "arm-ubuntu" image and
points to the gem5 component that would work with the disk image. The
arm-ubuntu disk image is based on Ubuntu's server cloud image for
arm available at (https://cloud-images.ubuntu.com/focal/current/).
The `.bashrc` file would be modified in such a way that it executes
a script passed from the gem5 configuration files (using the `m5 readfile`
instruction).

The instructions for bringing up QEMU emulation are based on
[Ubuntu's Wiki](https://wiki.ubuntu.com/ARM64/QEMU),
and the instructions for creating a cloud disk image are based on
[this guide](https://gist.github.com/oznu/ac9efae7c24fd1f37f1d933254587aa4).
More information about cloud-init can be found
[here](https://cloudinit.readthedocs.io/en/latest/topics/examples.html).

We assume the following directory structure while following the instructions
in this README file:

```
arm-ubuntu/
  |___ gem5/                                   # gem5 source code (to be cloned here)
  |
  |___ disk-image/
  |      |___ aarch64-ubuntu.img               # The ubuntu disk image should be downloaded and modified here
  |      |___ shared/                          # Auxiliary files needed for disk creation
  |      |      |___ serial-getty@.service     # Auto-login script
  |      |      |___ cloud-init/
  |      |             |___ configs/
  |      |                    |___ user-data   # Config containing login data, previously cloud.txt
  |      |                    |___ meta-data   # Required for cloud-init, currently empty
  |      |___ arm-ubuntu/
  |             |___ gem5_init.sh              # The script to be appended to .bashrc on the disk image
  |             |___ post-installation.sh      # The script manipulating the disk image
  |             |___ arm-ubuntu.json           # The Packer script
  |             |___ arm-ubuntu-image          # Output directory for the disk image
  |
  |
  |___ README.md                               # This README file
```

## Building the disk image

This requires an ARM cross compiler to be installed. The disk image is a 64-bit
ARM 64 (aarch64) disk image. Therefore, we only focus on the 64-bit version of
the cross compiler. It can be installed by:

```sh
sudo apt-get install g++-10-aarch64-linux-gnu gcc-10-aarch64-linux-gnu
```

In order to build the ARM based Ubuntu disk-image for with gem5, build the m5
utility in `gem5/util/m5` using the following:

```sh
git clone https://gem5.googlesource.com/public/gem5
cd gem5/util/m5
scons build/arm64/out/m5
```

Troubleshooting: You may need to edit the SConscript to point to the correct
cross compiler.
```
...
main['CXX'] = '${CROSS_COMPILE}g++-10'
...
```

# Installing QEMU for aarch64

On the host machine,

```sh
sudo apt-get install qemu-system-arm qemu-efi
```

# Installing cloud utilities

On the host machine,

```sh
sudo apt-get install cloud-utils
```

# Setting apt proxy

If running behind a proxy, set the proxy variables in 
`disk-image/shared/cloud-init/configs/user-data`

Note: Need to verify this is actually needed, I believe it is
but I can't say for certain as arm-ubuntu only uninstalls packages

# Building the disk imagee

In the `arm-ubuntu/disk-image` directory:

```
chmod +x build.sh
./build.sh
```

# Validating the image

You can verify the image works by modifying the gem5 config arm-ubuntu-run.py:
(Make sure to update the path to your gem5-resources directory)

```
diff --git a/configs/example/gem5_library/arm-ubuntu-run.py b/configs/example/gem5_library/arm-ubuntu-run.py                                                       
index 7f976f06db..acaf066e09 100644
--- a/configs/example/gem5_library/arm-ubuntu-run.py
+++ b/configs/example/gem5_library/arm-ubuntu-run.py
@@ -44,6 +44,7 @@ from gem5.isas import ISA
 from m5.objects import ArmDefaultRelease
  from gem5.utils.requires import requires
   from gem5.resources.workload import Workload
   +from gem5.resources.resource import Resource, DiskImageResource
    from gem5.simulate.simulator import Simulator
     from m5.objects import VExpress_GEM5_Foundation
      from gem5.coherence_protocol import CoherenceProtocol
      @@ -100,7 +101,11 @@ board = ArmBoard(
       # Here we set a full system workload. The "arm64-ubuntu-20.04-boot" boots
        # Ubuntu 20.04.

        -board.set_workload(Workload("arm64-ubuntu-20.04-boot"))
        +board.set_kernel_disk_workload(
        +    kernel=Resource("arm64-linux-kernel-5.4.49"),
        +    disk_image=DiskImageResource(local_path="/path/to/gem5-resources/src/arm-ubuntu/disk-image/arm-ubuntu/arm-ubuntu-image/packer-qemu", root_partition="1"),
        +    bootloader=Resource("arm64-bootloader-foundation"),
        +)
