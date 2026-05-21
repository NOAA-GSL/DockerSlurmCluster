#!/bin/bash

# Ensure SLURM_CPUS_ON_NODE is set
export SLURM_CPUS_ON_NODE=${SLURM_CPUS_ON_NODE:-$(cat /proc/cpuinfo | grep processor | wc -l)}
sudo sed -i "s/REPLACE_IT/${SLURM_CPUS_ON_NODE}/g" /etc/slurm/slurm.conf

sudo service munge start
sudo ssh-keygen -A
sudo service ssh start
sudo slurmd -N $SLURM_NODENAME

tail -f /dev/null
