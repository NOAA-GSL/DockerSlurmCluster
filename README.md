[![Docker Slurm](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml/badge.svg?branch=main)](https://github.com/NOAA-GSL/DockerSlurmCluster/actions/workflows/docker.yml)

# Slurm Cluster in Ubuntu Docker Images Using Docker Compose
This is an installation of a Slurm cluster inside Docker.

The container images support Ubuntu `24.04` and `26.04` and build Slurm `25.11.5` from source during image creation. CI builds and publishes images for both Ubuntu versions.

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

# Building with Custom Base Images

The cluster supports building with different Ubuntu base images and custom image tags for testing and version management.

## Configurable Variables

Defaults are set in the `.env` file and can be overridden via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `UBUNTU_BASE` | `ubuntu:26.04` | Ubuntu base image for all containers |
| `IMAGE_TAG` | `latest` | Tag applied to built images |
| `SLURM_CPUS_ON_NODE` | `8` | CPUs per Slurm node |

## Building with Different Ubuntu Versions

Build with Ubuntu 24.04:
```bash
UBUNTU_BASE=ubuntu:24.04 IMAGE_TAG=ubuntu-24.04-slurm-25.11.5 docker compose build
```

Build with Ubuntu 26.04:
```bash
UBUNTU_BASE=ubuntu:26.04 IMAGE_TAG=ubuntu-26.04-slurm-25.11.5 docker compose build
```

Or edit `.env` directly to change the defaults.

## Running a Specific Build

After building multiple versions, select which to run by setting `IMAGE_TAG`:
```bash
IMAGE_TAG=ubuntu-24.04-slurm-25.11.5 docker compose up -d
```

This allows multiple builds with different base images to coexist locally for testing purposes.

# Security and Image Hygiene

The CI workflow performs vulnerability scans against published images and fails on `HIGH`/`CRITICAL` findings that are fixable (`ignore-unfixed: true`).
