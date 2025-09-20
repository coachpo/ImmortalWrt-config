FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update base image, upgrade packages, and install build dependencies
RUN apt-get update -y \
    && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
        ack \
        antlr3 \
        asciidoc \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        build-essential \
        bzip2 \
        ccache \
        clang \
        cmake \
        cpio \
        curl \
        device-tree-compiler \
        ecj \
        fastjar \
        flex \
        gawk \
        gettext \
        gcc-multilib \
        g++-multilib \
        git \
        libgnutls28-dev \
        gperf \
        haveged \
        help2man \
        intltool \
        lib32gcc-s1 \
        libc6-dev-i386 \
        libelf-dev \
        libglib2.0-dev \
        libgmp-dev \
        libltdl-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses-dev \
        libpython3-dev \
        libreadline-dev \
        libssl-dev \
        libtool \
        libyaml-dev \
        lld \
        llvm \
        lrzsz \
        genisoimage \
        msmtp \
        nano \
        ninja-build \
        p7zip \
        p7zip-full \
        patch \
        pkgconf \
        python3 \
        python3-pip \
        python3-ply \
        python3-docutils \
        python3-pyelftools \
        qemu-utils \
        re2c \
        rsync \
        scons \
        squashfs-tools \
        subversion \
        swig \
        texinfo \
        uglifyjs \
        upx-ucl \
        unzip \
        vim \
        wget \
        xmlto \
        xxd \
        zlib1g-dev \
        zstd \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and set as default
ARG USERNAME=builder
ARG USER_UID=1001
ARG USER_GID=121
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && mkdir -p /workdir \
    && chown -R ${USER_UID}:${USER_GID} /workdir
ENV HOME=/home/${USERNAME}
USER ${USERNAME}

WORKDIR /workdir


