# Este Dockerfile define un container con gcc y qemu para poder correr
FROM debian:buster-slim as build-env
WORKDIR /root/

RUN apt-get update && apt-get -y install \
    git \
    gcc-aarch64-linux-gnu \
    build-essential \
    python \
    pkg-config \
    zlib1g-dev \
    libglib2.0-dev \
    libpixman-1-dev \
    gdb-multiarch \
    qemu-system-arm

  # Instalar GDB Dashboard
RUN git clone https://github.com/cyrus-and/gdb-dashboard.git /root/.gdb-dashboard \
&& echo "source /root/.gdb-dashboard/.gdbinit" >> /root/.gdbinit

WORKDIR /local
ENTRYPOINT ["/bin/bash"]
