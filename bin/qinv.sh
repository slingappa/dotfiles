#!/usr/bin/expect

set sid [lindex $argv 0]
spawn ssh -o "ServerAliveInterval=0" -o StrictHostKeyChecking=accept-new root@localhost -p${sid}2222
#spawn bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
expect "password:"
send "0penBmc\r"
sleep 2
send "obmcutil state\r"
#send "journalctl -f  | grep -i bmcweb\r"
send "systemctl restart xyz.openbmc_project.EntityManager.service \r"
#send "busctl tree | grep -r inventory \r"
send "busctl tree xyz.openbmc_project.FruDevice \r"
send "hexdump -C /sys/bus/i2c/devices/2-0050/eeprom \r"
interact
