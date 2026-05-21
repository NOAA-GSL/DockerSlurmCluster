#!/bin/bash

sudo sed -i "s/REPLACE_IT/${SLURM_CPUS_ON_NODE}/g" /etc/slurm/slurm.conf

sudo service munge start
sudo ssh-keygen -A
sudo service ssh start
sudo slurmd -N $SLURM_NODENAME

tail -f /dev/null
