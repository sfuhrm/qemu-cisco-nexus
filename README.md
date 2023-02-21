# QEMU based Nexus / NX-OS simulation approach

## Summary

A QEMU based approach that shows how to boot a QEMU NX-OS VM image
as it can be downloaded from Cisco and initializes the networking
of the NX-OS device.

## Background

The setup serves as a demonstration how to set up test devices in an automated
way for developing network applications.

## Preconditions

You need to have the following Debian packages installed:

* `qemu-system-x86`
* `qemu-utils`
* `ovmf`
* `expect`

You need to download and store your QCOW2 NX-OS image in a location that
needs to be specified by the SOURCE_IMAGE environment variable in
`qemu-snapshot-and-start.sh`.

## Components

There are the following components:

* `qemu-snapshot-and-start.sh`: The script that creates a new snapshot from an image, and spawns a new QEMU from it.
* `qemu-start-from-snapshot.sh`: The script that spawns a new QEMU with a pre-existing image.
* `expect.ex`: An expect script that fights through the NX-OS
  configuration until a initial user/password is set and
  the management interface has a working network via QEMUs DHCP.

## Status

The QEMU launcher is creating a snapshot first so we don't alter the original
image file. The QEMU launcher will stop in the QEMU command prompt ('(qemu)') which
might be confusing, but this is ok.
The QEMU monitor commands are listed [here](https://qemu-project.gitlab.io/qemu/system/monitor.html).

The expect script is working to set up management interface via DHCP.
The expect script does:

* Setup admin user 'admin' with password 'admin'.
* Setup login user 'vagrant' with password 'vagrant'.
* Setup console port 2023 (usable via telnet).
* Setup port binding to TCP port 3022 on host towards TCP port 22 on guest (usable via SSH).
* Copies the running-config to the startup-config to save user and network configs.

## How to use

Define the image location in $SOURCE_IMAGE, then start the `qemu-snapshot-and-start.sh` in the first shell,
so QEMU can boot up.

Start `expect.ex` right away in a second shell so the starting VM will be configured.

The management interface of the simulated device will be available via
SSH:

```bash
$  ssh -oPubKeyAuthentication=false -p3022 admin@localhost
The authenticity of host '[localhost]:3022 ([127.0.0.1]:3022)' can't be established.
RSA key fingerprint is SHA256:FronHu+9JxcRpCOvGcwpKEF+MZdfWoS94cM6MhcGghg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[localhost]:3022' (RSA) to the list of known hosts.
User Access Verification
Password: 

Bad terminal type: "xterm-256color". Will assume vt100.
Cisco NX-OS Software
Copyright (c) 2002-2020, Cisco Systems, Inc. All rights reserved.
Nexus 9000v software ("Nexus 9000v Software") and related documentation,
files or other reference materials ("Documentation") are
the proprietary property and confidential information of Cisco
Systems, Inc. ("Cisco") and are protected, without limitation,
pursuant to United States and International copyright and trademark
laws in the applicable jurisdiction which provide civil and criminal
penalties for copying or distribution without Cisco's authorization.

Any use or disclosure, in whole or in part, of the Nexus 9000v Software
or Documentation to any third party for any purposes is expressly
prohibited except as otherwise authorized by Cisco in writing.
The copyrights to certain works contained herein are owned by other
third parties and are used and distributed under license. Some parts
of this software may be covered under the GNU Public License or the
GNU Lesser General Public License. A copy of each such license is
available at
http://www.gnu.org/licenses/gpl.html and
http://www.gnu.org/licenses/lgpl.html
***************************************************************************
*  Nexus 9000v is strictly limited to use for evaluation, demonstration   *
*  and NX-OS education. Any use or disclosure, in whole or in part of     *
*  the Nexus 9000v Software or Documentation to any third party for any   *
*  purposes is expressly prohibited except as otherwise authorized by     *
*  Cisco in writing.                                                      *
***************************************************************************
switch# 
```
