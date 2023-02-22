#!/usr/bin/expect

#
# Expect script to configure a NX-OS virtual
# switch to
#
# * use dummy admin password 'admin'
# * configure the mgmt0 interface to use DHCP
#

set startTime [clock seconds]

## Access CLI
set adminUser "admin"
set adminPassword "admin"
set loginUser "vagrant"
set loginPassword "vagrant"
set consoleHost localhost
set consolePort 2023

set start_time [ clock seconds ]
## Expect Parameters
set timeout 20
set successMsg "Status: Success"
set failureMsg "Status: Failure"

proc log {level color msg} {
    set black "\u001b\[30m"
    set currentTime [clock seconds]
    set timeFormat [clock format $currentTime -format %H:%M:%S]
    puts "\n$color$timeFormat $level $msg$black";
}

proc logInfo {msg} {
    log "INFO" "\u001b\[48m\u001b\[32m" $msg;
}

proc errorExit {msg} {
    log "ERROR" "\u001b\[48m\u001b\[31m" "There was an error: $msg";
    exit 10;
}

logInfo "Setting up NX-OS. Admin user is $adminUser, loginUser is $loginUser.";
spawn netcat $consoleHost $consolePort
expect_after eof { errorExit "netcat $consoleHost $consolePort failed" }

set timeout 10

# CR just to get the prompt if we are stuck in boot loader
send "\r"

# reset colors / styles just in case the BIOS set background color to black
puts "\u001b\[0m"

set timeout 300

expect "Abort Power On Auto Provisioning" {send "yes\r"} \
    "login: " { logInfo "OK: Switch is already configured and ready for login. Quitting."; exit; }
    timeout { errorExit "Failed to abort POAP!"; }
logInfo "Aborted POAP"

set timeout 60

expect "Do you want to enforce secure password standard" {send "no\r"} \
    timeout { errorExit "Failed to set insecure password!"; }
logInfo "No secure passwords..."

set timeout 10

expect "Enter the password for \"$adminUser\":" {send "$adminPassword\r"} \
    timeout { errorExit "Failed to set admin password!"; }

expect "Confirm the password for \"$adminUser\":" {send "$adminPassword\r"} \
    timeout { errorExit "Failed to confirm admin password!"; }
logInfo "Set admin password"

expect "Would you like to enter the basic configuration dialog" {send "no\r"} \
    timeout { errorExit "Timeout waiting for basic config dialog"; }
logInfo "Basic configuration dialog..."

expect "login:" {send "$adminUser\r"} \
    timeout { errorExit "Timeout waiting for login"; }
expect "Password:" {send "$adminPassword\r"} \
    timeout { errorExit "Timeout waiting for Password"; }
logInfo "Login..."

set timeoutprompt "Timeout waiting for prompt";
expect "switch#" {send "conf t\r"} \
    timeout { errorExit $timeoutprompt; }

# list boot flash so we get the name of the boot image
expect "switch(config)#" {send "dir bootflash:\r"} \
    timeout { errorExit $timeoutprompt; }

expect -re ".* (nxos.*\.bin)" {
    set nxos_image $expect_out(1,string)
    logInfo "Detected NXOS image in bootflash: $nxos_image.";
    } \
    timeout { errorExit $timeoutprompt; }

expect "switch(config)#" {send "boot nxos bootflash:///$nxos_image\r"} \
    timeout { errorExit $timeoutprompt; }

set timeout 60
expect "switch(config)#" {send "feature dhcp\r"} \
    timeout { errorExit $timeoutprompt; }

set timeout 10
expect "switch(config)#" {send "int mgmt0\r"} \
    timeout { errorExit $timeoutprompt; }

expect "switch(config-if)#" {send "ip address dhcp\r"} \
    timeout { errorExit $timeoutprompt; }

expect "switch(config-if)#" {send "exit\r"} \
    timeout { errorExit $timeoutprompt; }

expect "switch(config)#" {send "copy running-config startup-config\r"} \
    timeout { errorExit $timeoutprompt; }

expect "switch(config)#" {send "exit\r"} \
    timeout { errorExit $timeoutprompt; }

expect "switch#" {send "exit\r"} \
    timeout { errorExit $timeoutprompt; }

set endTime [clock seconds]
set duration [expr $endTime-$startTime]

logInfo "OK: Expect script finished with success. Expect script took $duration seconds.";
