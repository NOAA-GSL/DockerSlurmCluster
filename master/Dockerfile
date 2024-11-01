FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    mariadb-server \
    munge \
    vim \
    wget \
    devscripts \
    equivs \
    fakeroot \
    libbpf-dev \
    libdbus-1-dev \
    libhwloc-dev \
    openssh-server \
    sudo \
 && cd /tmp \
 && wget https://download.schedmd.com/slurm/slurm-23.11.7.tar.bz2 \
 && tar -xaf slurm-23.11.7.tar.bz2 \
 && cd slurm-23.11.7 \
 && mk-build-deps -t "apt-get -y" -i debian/control \
 && debuild -b -uc -us \
 && cd .. \
 && ARCH=$(dpkg --print-architecture) \
 && dpkg --install slurm-smd_23.11.7-1_${ARCH}.deb \
 && dpkg --install slurm-smd-client_23.11.7-1_${ARCH}.deb \
 && dpkg --install slurm-smd-slurmctld_23.11.7-1_${ARCH}.deb \
 && dpkg --install slurm-smd-dev_23.11.7-1_${ARCH}.deb \
 && dpkg --install slurm-smd-libpmi0_23.11.7-1_${ARCH}.deb \
 && dpkg --install slurm-smd-libpmi2-0_23.11.7-1_${ARCH}.deb \
 && rm -rf /tmp/slurm* \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m admin -s /usr/bin/bash -d /home/admin \
 && echo "admin:admin" | chpasswd \
 && adduser admin sudo \
 && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN useradd -m slurm -s /usr/bin/bash -d /home/slurm \
 && echo "slurm:slurm" | chpasswd

RUN mkdir /var/run/sshd \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && chmod -x /etc/update-motd.d/* \
 && rm -f /etc/legal

COPY munge.key /etc/munge/
COPY slurm.conf /etc/slurm/
COPY cgroup.conf /etc/slurm/
COPY docker-entrypoint.sh /etc/slurm/

RUN chown munge:munge etc/munge/munge.key \
 && mkdir /var/spool/slurmctld \
 && chown slurm:slurm /var/spool/slurmctld \
 && chmod 755 /var/spool/slurmctld \
 && chown slurm:slurm /etc/slurm \
 && chown slurm:slurm /etc/slurm/*.conf \
 && chmod 600 /etc/munge/munge.key \
 && chmod 775 /etc/slurm \
 && chmod 775 /etc/slurm/*.conf

RUN systemctl enable slurmctld

COPY ssh /home/admin/.ssh

RUN chown -R admin:admin /home/admin/.ssh \
 && chmod -R 700 /home/admin/.ssh

EXPOSE 22 6817 6818 6819 3306

WORKDIR /home/admin

ENTRYPOINT ["/etc/slurm/docker-entrypoint.sh"]
