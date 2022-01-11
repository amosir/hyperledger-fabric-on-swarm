#!/bin/bash
base_ip="10.245.150."
for i in {86..92}; do
    host="${base_ip}${i}"
    rsync -vrlu --delete ./ root@${host}:/root/hyperledger-fabric-on-swarm
done
