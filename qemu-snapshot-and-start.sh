#! /bin/bash

# see here for images:
# https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/93x/nx-osv-93-95/configuration/guide/cisco-nexus-9000v-9300v-9500v-guide-93x/m-nexus-9000v-deployment.html

if [ ! -f "${SOURCE_IMAGE}" ]; then
   echo "ERROR: The \$SOURCE_IMAGE env variable needs to point to your NXOS QCOW2 file."
   echo "At the moment, the variable contains the content: ${SOURCE_IMAGE}"
   exit 10
fi
# snapshot will be created
SNAPSSHOT_IMAGE=snapshot.qcow2

# create snapshot
qemu-img create -f qcow2 -b ${SOURCE_IMAGE} ${SNAPSSHOT_IMAGE}

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
