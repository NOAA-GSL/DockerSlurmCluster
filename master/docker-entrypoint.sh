#!/bin/bash

export SLURM_CPUS_ON_NODE=${SLURM_CPUS_ON_NODE:-$(cat /proc/cpuinfo | grep processor | wc -l)}
sudo sed -i "s/REPLACE_IT/${SLURM_CPUS_ON_NODE}/g" /etc/slurm/slurm.conf

sudo -u munge /usr/sbin/munged

sudo service mariadb start
until sudo mariadb -e "SELECT 1" >/dev/null 2>&1; do
	sleep 1
done
sudo mariadb <<-SQL
	DROP USER IF EXISTS 'slurm'@'localhost';
	CREATE USER 'slurm'@'localhost' IDENTIFIED VIA unix_socket;
	CREATE DATABASE IF NOT EXISTS slurm_acct_db;
	GRANT ALL ON slurm_acct_db.* TO 'slurm'@'localhost';
	FLUSH PRIVILEGES;
SQL

sudo -u slurm slurmdbd
until sudo -u slurm sacctmgr -i show cluster >/dev/null 2>&1; do
	sleep 1
done
sudo -u slurm sacctmgr -i add cluster cluster >/dev/null 2>&1 || true

sudo slurmctld
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	sudo ssh-keygen -A
fi
sudo service ssh start

tail -f /dev/null
