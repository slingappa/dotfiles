#!/usr/bin/expect

set sid [lindex $argv 0]
#spawn ssh -o "ServerAliveInterval=0" -o StrictHostKeyChecking=accept-new root@localhost -p${sid}10004
spawn ssh -o "ServerAliveInterval=0" -o StrictHostKeyChecking=accept-new root@localhost -p${sid}2222
#spawn bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
expect "password:"
send "0penBmc\r"
sleep 2
send "obmcutil state\r"
#send "journalctl -f  | grep -i bmcweb\r"
send "journalctl -f \r"
interact
