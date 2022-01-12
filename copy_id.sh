#!/bin/bash
if [ ! -e "$HOME/.ssh/id_rsa.pub" ]; then
    ssh-keygen -t rsa
fi
hosts=('peer0.org1.example.com' 'peer1.org1.example.com' 'peer0.org2.example.com' 'peer1.org2.example.com' 'orderer.example.com' 'client0.example.com' 'client1.example.com')
for host in ${hosts[@]}; do
    if [ "$host" != "$HOSTNAME" ]; then
        echo "copy public key to ${host}, this is ${HOSTNAME}"
        ssh-copy-id -i ~/.ssh/id_rsa.pub root@"${host}"
    fi
done
