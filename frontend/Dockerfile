ARG UBUNTU_BASE=ubuntu:26.04
FROM ${UBUNTU_BASE}

ARG SLURM_VERSION=25.11.5
ARG MUNGE_VERSION=0.5.18
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    mariadb-server \
    vim \
    wget \
    devscripts \
    equivs \
    fakeroot \
    libbpf-dev \
    libdbus-1-dev \
    libhwloc-dev \
    libssl-dev \
    openssh-server \
    pkg-config \
    sudo \
 && groupadd --system munge \
 && useradd --system --gid munge --home /var/lib/munge --shell /usr/sbin/nologin munge \
 && cd /tmp \
 && wget https://github.com/dun/munge/releases/download/munge-${MUNGE_VERSION}/munge-${MUNGE_VERSION}.tar.xz \
 && tar -xaf munge-${MUNGE_VERSION}.tar.xz \
 && cd munge-${MUNGE_VERSION} \
 && ARCH=$(dpkg --print-architecture) \
 && MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH) \
 && MV=${MUNGE_VERSION}-1 \
 && ./configure --prefix=/usr --libdir=/usr/lib/${MULTIARCH} --sysconfdir=/etc --localstatedir=/var --runstatedir=/run \
 && make -j"$(nproc)" \
 && make install DESTDIR=/tmp/munge-stage \
 && cd /tmp \
 && mkdir -p libmunge2-pkg/DEBIAN libmunge2-pkg/usr/lib/${MULTIARCH} \
 && cp -a munge-stage/usr/lib/${MULTIARCH}/libmunge.so.2* libmunge2-pkg/usr/lib/${MULTIARCH}/ \
 && { echo "Package: libmunge2"; \
      echo "Version: ${MV}"; \
      echo "Section: libs"; \
      echo "Priority: optional"; \
      echo "Architecture: ${ARCH}"; \
      echo "Multi-Arch: same"; \
      echo "Maintainer: DockerSlurmCluster <noreply@local>"; \
      echo "Description: MUNGE shared library (upstream ${MUNGE_VERSION})"; \
    } > libmunge2-pkg/DEBIAN/control \
 && echo "libmunge 2 libmunge2 (>= ${MUNGE_VERSION})" > libmunge2-pkg/DEBIAN/shlibs \
 && dpkg-deb --root-owner-group --build libmunge2-pkg libmunge2_${MV}_${ARCH}.deb \
 && mkdir -p libmunge-dev-pkg/DEBIAN libmunge-dev-pkg/usr/include libmunge-dev-pkg/usr/lib/${MULTIARCH}/pkgconfig \
 && cp -a munge-stage/usr/include/munge.h libmunge-dev-pkg/usr/include/ \
 && cp -a munge-stage/usr/lib/${MULTIARCH}/libmunge.so libmunge-dev-pkg/usr/lib/${MULTIARCH}/ \
 && cp -a munge-stage/usr/lib/${MULTIARCH}/pkgconfig/munge.pc libmunge-dev-pkg/usr/lib/${MULTIARCH}/pkgconfig/ \
 && { echo "Package: libmunge-dev"; \
      echo "Version: ${MV}"; \
      echo "Section: libdevel"; \
      echo "Priority: optional"; \
      echo "Architecture: ${ARCH}"; \
      echo "Depends: libmunge2 (= ${MV})"; \
      echo "Maintainer: DockerSlurmCluster <noreply@local>"; \
      echo "Description: MUNGE development files (upstream ${MUNGE_VERSION})"; \
    } > libmunge-dev-pkg/DEBIAN/control \
 && dpkg-deb --root-owner-group --build libmunge-dev-pkg libmunge-dev_${MV}_${ARCH}.deb \
 && mkdir -p munge-pkg/DEBIAN munge-pkg/usr/bin munge-pkg/usr/sbin \
 && cp -a munge-stage/usr/bin/. munge-pkg/usr/bin/ \
 && cp -a munge-stage/usr/sbin/. munge-pkg/usr/sbin/ \
 && { echo "Package: munge"; \
      echo "Version: ${MV}"; \
      echo "Section: admin"; \
      echo "Priority: optional"; \
      echo "Architecture: ${ARCH}"; \
      echo "Depends: libmunge2 (= ${MV})"; \
      echo "Maintainer: DockerSlurmCluster <noreply@local>"; \
      echo "Description: MUNGE authentication service (upstream ${MUNGE_VERSION})"; \
    } > munge-pkg/DEBIAN/control \
 && dpkg-deb --root-owner-group --build munge-pkg munge_${MV}_${ARCH}.deb \
 && dpkg --install libmunge2_${MV}_${ARCH}.deb libmunge-dev_${MV}_${ARCH}.deb munge_${MV}_${ARCH}.deb \
 && mkdir -p /etc/munge /var/lib/munge /var/log/munge /run/munge \
 && chown -R munge:munge /etc/munge /var/lib/munge /var/log/munge /run/munge \
 && chmod 0700 /etc/munge /var/lib/munge /var/log/munge \
 && wget https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 \
 && tar -xaf slurm-${SLURM_VERSION}.tar.bz2 \
 && cd slurm-${SLURM_VERSION} \
 && mk-build-deps -t "apt-get -y" -i debian/control \
 && debuild -b -uc -us \
 && cd .. \
 && ARCH=$(dpkg --print-architecture) \
 && dpkg --install slurm-smd_${SLURM_VERSION}-1_${ARCH}.deb \
 && dpkg --install slurm-smd-client_${SLURM_VERSION}-1_${ARCH}.deb \
 && dpkg --install slurm-smd-dev_${SLURM_VERSION}-1_${ARCH}.deb \
 && dpkg --install slurm-smd-libpmi0_${SLURM_VERSION}-1_${ARCH}.deb \
 && dpkg --install slurm-smd-libpmi2-0_${SLURM_VERSION}-1_${ARCH}.deb \
 && rm -rf /tmp/munge* /tmp/libmunge* /tmp/slurm* \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/ssh/ssh_host_* \
 && rm -rf /usr/bin/pebble /var/lib/pebble

# Compatibility symlinks for libmunge. Debian/Ubuntu install libmunge under multiarch
# paths (/usr/lib/x86_64-linux-gnu/ on amd64, /usr/lib/aarch64-linux-gnu/ on arm64),
# but autotools projects that aren't multiarch-aware look in /usr/lib/ and
# /usr/lib/pkgconfig/. Add symlinks so those projects' configure can find munge.
# Notably, pmix 5.0.5 (used by openmpi in spack-stack downstream builds) hits this.
RUN ARCH_TRIPLET="$(uname -m)-linux-gnu" \
 && test -f /usr/lib/${ARCH_TRIPLET}/libmunge.so || { \
        echo "ERROR: /usr/lib/${ARCH_TRIPLET}/libmunge.so missing -- is libmunge-dev installed?"; \
        exit 1; \
    } \
 && mkdir -p /usr/lib/pkgconfig \
 && ln -sf ${ARCH_TRIPLET}/libmunge.so /usr/lib/libmunge.so \
 && ln -sf ${ARCH_TRIPLET}/libmunge.so.2 /usr/lib/libmunge.so.2 \
 && ln -sf ${ARCH_TRIPLET}/pkgconfig/munge.pc /usr/lib/pkgconfig/munge.pc

RUN useradd -m admin -s /usr/bin/bash -d /home/admin \
 && echo "admin:admin" | chpasswd \
 && adduser admin sudo \
 && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN useradd -m slurm -s /usr/bin/bash -d /home/slurm \
 && echo "slurm:slurm" | chpasswd

RUN mkdir -p /var/run/sshd \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && chmod -x /etc/update-motd.d/* \
 && rm -f /etc/legal

COPY munge.key /etc/munge/
COPY slurm.conf /etc/slurm/
COPY cgroup.conf /etc/slurm/
COPY docker-entrypoint.sh /etc/slurm/

RUN chown munge:munge etc/munge/munge.key \
 && chown slurm:slurm /etc/slurm \
 && chown slurm:slurm /etc/slurm/*.conf \
 && chmod 600 /etc/munge/munge.key \
 && chmod 775 /etc/slurm \
 && chmod 775 /etc/slurm/*.conf

COPY ssh /home/admin/.ssh

RUN chown -R admin:admin /home/admin/.ssh \
 && chmod -R 700 /home/admin/.ssh

WORKDIR /home/admin

EXPOSE 22 8888

ENV USER=admin
ENV SHELL=bash

ENTRYPOINT ["/etc/slurm/docker-entrypoint.sh"]
