[![Docker Slurm](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml/badge.svg?branch=main)](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml)

# Slurm Cluster in Ubuntu Docker Images Using Docker Compose
This is an installation of a Slurm cluster inside Docker.

The container images now pin Ubuntu `26.04` by digest and build Slurm `25.11.5` from source during image creation.

Pinned Ubuntu base image: ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

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

# Security and Image Hygiene

The Dockerfiles are pinned to an immutable Ubuntu 26.04 digest for reproducibility.

The CI workflow performs vulnerability scans against published images and fails on `HIGH`/`CRITICAL` findings that are fixable (`ignore-unfixed: true`).

The `.github/workflows/refresh-ubuntu-digest.yml` workflow runs weekly and opens a pull request when a newer `ubuntu:26.04` digest is available.
