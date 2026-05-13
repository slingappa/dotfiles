#!/usr/bin/expect

set item [lindex $argv 0];

spawn ssh root@localhost -p2222 "ventana_dbus_init.sh"
#spawn ssh root@localhost -p2222 "ventana_i2c_util.sh $item"
#spawn ssh root@localhost -p2222 "ventana_i2c_util.sh 13"
#spawn bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
expect "password:"
send "0penBmc\r"
sleep 2
interact
