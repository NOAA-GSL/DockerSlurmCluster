[![Docker Slurm](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml/badge.svg?branch=main)](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml)

# Slurm Cluster in Ubuntu Docker Images Using Docker Compose
This is an installation of a Slurm cluster inside Docker.

This is an adaptation of the work done by Rodrigo Ancavil del Pino:

https://medium.com/analytics-vidhya/slurm-cluster-with-docker-9f242deee601

There are three containers:

* A front-end container that acts as a Slurm cluster front-end node
* A master container that acts as a Slurm master node
* A node container that acts as a Slurm compute node

These containers are launched using Docker Compose to build
a fully functioning Slurm cluster.  A `docker-compose.yml`
file defines the cluster, specifying ports and volumes to
be shared.  Multiple instances of the node container can be
used to create clusters of different sizes.  The cluster
behaves as if it were running on multiple nodes even if the
containers are all running on the same host machine.

# Quick Start

To start the slurm cluster environment:
```
docker-compose -f docker-compose.yml up -d
```
To stop the cluster:
```
docker-compose -f docker-compose.yml stop
```
To check the cluster logs:
```
docker-compose -f docker-compose.yml logs -f
```
(stop logs with CTRL-c")

To check status of the cluster containers:
```
docker-compose -f docker-compose.yml ps
```
To check status of Slurm:
```
docker exec slurm-frontend sinfo
```
To run a Slurm job:
```
docker exec slurm-frontend srun hostname
```

# SSH between Slurm cluster nodes

In some instances it may be useful to have the ability
to ssh to a given Slurm cluster node. Each container
runs an ssh service to provide this capability. If
passwordless ssh access to Slurm nodes is required,
**NEW** ssh keys will need to be generated after the
cluster is started. For example:
```
docker exec -it slurm-frontend ssh-keygen -t rsa -f /home/admin/.ssh/id_rsa -N ""
docker exec -it slurm-frontend cp /home/admin/.ssh/id_rsa.pub /home/admin/.ssh/authorized_keys
```
This will allow you to (for example) ssh from the
frontend node to the compute nodes:
```
admin@slurmfrontend:~$ ssh slurmnode1
admin@slurmnode1:~$
```

## WARNING

***ALWAYS GENERATE NEW KEYS AS SHOWN ABOVE*** every
time a cluster is started. And **NEVER**, under any
circumstances whatsoever, reuse ssh keys from
previous cluster instances or from any other source.
