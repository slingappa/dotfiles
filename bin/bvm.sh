bash -c "until `ssh root@localhost -p2222`; do echo trying again; done"
