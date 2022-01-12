#!/bin/bash
base_ip="10.245.150."
for i in {86..92}; do
    host="${base_ip}${i}"
    if [ "$host" != "$HOSTNAME" ]; then
        echo "transfer to ${host}"
        rsync -vrlu --exclude '.git' --exclude '.vscode' --exclude '.gitignore' ./ root@${host}:/root/hyperledger-fabric-on-swarm
    fi
done
