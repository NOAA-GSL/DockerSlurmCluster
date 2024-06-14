#!/bin/bash

export SLURM_CPUS_ON_NODE=$(cat /proc/cpuinfo | grep processor | wc -l)
sudo sed -i "s/REPLACE_IT/${SLURM_CPUS_ON_NODE}/g" /etc/slurm/slurm.conf

sudo service munge start
sudo service ssh start

ssh-keygen -t rsa -f /home/admin/.ssh/id_rsa -N ""
cp /home/admin/.ssh/id_rsa.pub /home/admin/.ssh/authorized_keys

tail -f /dev/null
