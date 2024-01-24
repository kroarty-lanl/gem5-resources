#!/bin/bash

qemu-system-x86_64 \
    -hda jammy-server-expanded.img \
    -hdb my-seed.img \
    -machine accel=kvm:tcg \
    -cpu host \
    -m 8192 \
    -nographic \
    -net nic \
    -net user,hostfwd=tcp::5555-:22
