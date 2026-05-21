#!/bin/bash

export SLURM_CPUS_ON_NODE=${SLURM_CPUS_ON_NODE:-$(cat /proc/cpuinfo | grep processor | wc -l)}
sudo sed -i "s/REPLACE_IT/${SLURM_CPUS_ON_NODE}/g" /etc/slurm/slurm.conf

sudo service munge start
sudo ssh-keygen -A
sudo service ssh start

# Generate SSH key and set up shared authorized_keys
mkdir -p /home/admin/.ssh
ssh-keygen -t rsa -f /home/admin/.ssh/id_rsa -N ""
cp /home/admin/.ssh/id_rsa.pub /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
chmod 700 /home/admin/.ssh
chmod 600 /home/admin/.ssh/authorized_keys

tail -f /dev/null
