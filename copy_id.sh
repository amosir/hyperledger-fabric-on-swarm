#!/bin/bash
if [ ! -e "$HOME/.ssh/id_rsa.pub" ]; then
    ssh-keygen -t rsa
fi
hosts=('10_245_150_86' '10_245_150_87' '10_245_150_88' '10_245_150_89' '10_245_150_90')
for host in ${hosts[@]}; do
    if [ "$host" != "$HOSTNAME" ]; then
        echo "copy public key to ${host}, this is ${HOSTNAME}"
        ssh-copy-id -i ~/.ssh/id_rsa.pub root@"${host}"
    fi
done
