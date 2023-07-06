FROM ubuntu:20.04

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    mariadb-server \
    munge \
    vim \
    wget
    
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y \
    openssh-server \
    slurm-client \
    slurmd \
    sudo

RUN useradd -m admin -s /usr/bin/bash -d /home/admin \
 && echo "admin:admin" | chpasswd \
 && adduser admin sudo \
 && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
RUN mkdir /var/run/sshd \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && chmod -x /etc/update-motd.d/* \
 && rm -f /etc/legal

COPY ssh /home/admin/.ssh

RUN chown -R admin:admin /home/admin/.ssh \
 && chmod -R 700 /home/admin/.ssh

COPY slurm.conf /etc/slurm-llnl/
COPY cgroup.conf /etc/slurm-llnl/
COPY docker-entrypoint.sh /etc/slurm-llnl/

EXPOSE 22 6817 6818 6819

ENTRYPOINT ["/etc/slurm-llnl/docker-entrypoint.sh"]
