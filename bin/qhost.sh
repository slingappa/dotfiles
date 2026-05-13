#!/usr/bin/expect
set sid [lindex $argv 0]
spawn ssh -o StrictHostKeyChecking=accept-new root@localhost -p${sid}2200
#spawn bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
expect "password:"
send "0penBmc\r"
sleep 2
expect "ubuntu login:"
send "ubuntu\r"
expect "password:"
send "ventana\r"
interact
