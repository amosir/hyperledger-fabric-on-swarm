#!/bin/bash
hosts=('10_245_150_86' '10_245_150_87' '10_245_150_88' '10_245_150_89' '10_245_150_90')
for host in ${hosts[@]}; do
    if [ "$host" != "$HOSTNAME" ]; then
        echo "transfer to ${host}"
        rsync -vrlu --exclude '.git' --exclude '.vscode' --exclude '.gitignore' --exclude './bin' ./ root@${host}:/root/hyperledger-fabric-on-swarm/
    fi
done
