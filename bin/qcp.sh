#!/usr/bin/expect

set file [lindex $argv 0]
set path [lindex $argv 1]

#spawn scp -P2222 /home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/../.././meta-ventana/meta-tunga/recipes-ventana/platform/ventana-utils/ventana_i2c_util.sh  /home/redpanda/git/ventana_openbmc_ws/src/openbmc/meta-ventana/meta-tunga/recipes-ventana/platform/ventana-platform-init/ventana_dbus_init.sh root@localhost:/usr/sbin/
spawn scp -P2222 ${file} ${path}

#spawn bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
expect "password:"
send "0penBmc\r"
sleep 2
send "obmcutil state\r"
interact
