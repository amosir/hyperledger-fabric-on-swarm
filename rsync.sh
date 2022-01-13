#!/bin/bash
hosts=('peer0.org1.example.com' 'peer1.org1.example.com' 'peer0.org2.example.com' 'peer1.org2.example.com' 'orderer.example.com' 'client0.example.com' 'client1.example.com')
for host in ${hosts[@]}; do
    if [ "$host" != "$HOSTNAME" ]; then
        echo "transfer to ${host}"
        rsync -vrlu --exclude '.git' --exclude '.vscode' --exclude '.gitignore' ./ root@${host}:/root/hyperledger-fabric-on-swarm/
    fi
done
