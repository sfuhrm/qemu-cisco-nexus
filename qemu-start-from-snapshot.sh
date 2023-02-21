#! /bin/bash

# existing snapshot will be used
SNAPSSHOT_IMAGE=snapshot.qcow2

# start qemu
qemu-system-x86_64 -smp 2 -enable-kvm \
   -nographic \
   -bios /usr/share/qemu/OVMF.fd \
   -m 8192 \
   -serial telnet:localhost:2023,server=on,wait=off \
   -device ahci,id=ahci0,bus=pci.0 -drive file=${SNAPSSHOT_IMAGE},if=none,id=drive-sata-disk0,id=drive-sata-disk0,format=qcow2 \
   -device ide-hd,bus=ahci0.0,drive=drive-sata-disk0,id=drive-sata-disk0,bootindex=1 \
   -netdev user,id=net0,hostfwd=tcp::3022-:22,hostfwd=tcp::3080-:80,hostfwd=tcp::3443-:443 \
   -device e1000,netdev=net0,mac=aa:bb:cc:dd:ee:ff,multifunction=on,romfile=,bootindex=3
