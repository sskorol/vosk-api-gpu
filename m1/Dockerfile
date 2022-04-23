FROM messense/manylinux_2_24-cross:aarch64

LABEL description="A docker image for building Kaldi and Vosk on Apple M1"
LABEL maintainer="serhii.s.korol@gmail.com"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        libffi-dev \
        libpcre3-dev \
        zlib1g-dev \
        automake \
        autoconf \
        libtool \
        cmake \
        nano \
        python3 \
        python3-pip \
        python3-wheel \
        python3-setuptools \
        python3-cffi \
    && rm -rf /var/lib/apt/lists/*

ARG OPENBLAS_ARCH=ARMV8
ARG ARM_HARDWARE_OPTS="-mfloat-abi=hard -mfpu=neon"

RUN cd /opt \
    && git clone -b vosk --single-branch https://github.com/alphacep/kaldi \
    && cd /opt/kaldi/tools \
    && git clone -b v0.3.13 --single-branch https://github.com/xianyi/OpenBLAS \
    && git clone -b v3.2.1  --single-branch https://github.com/alphacep/clapack \
    && make -C OpenBLAS ONLY_CBLAS=1 TARGET="${OPENBLAS_ARCH}" HOSTCC=gcc USE_LOCKING=1 USE_THREAD=0 all \
    && make -C OpenBLAS PREFIX=$(pwd)/OpenBLAS/install install \
    && mkdir -p clapack/BUILD && cd clapack/BUILD && cmake .. && make -j $(nproc) && find . -name "*.a" | xargs cp -t ../../OpenBLAS/install/lib \
    && cd /opt/kaldi/tools \
    && git clone --single-branch https://github.com/alphacep/openfst openfst \
    && cd openfst \
    && autoreconf -i \
    && CFLAGS="-g -O3" ./configure --prefix=/opt/kaldi/tools/openfst --enable-static --enable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic --disable-bin \
    && make -j $(nproc) && make install \
    && cd /opt/kaldi/src \
    && sed -i "s:-mfloat-abi=hard -mfpu=neon:${ARM_HARDWARE_OPTS}:g" makefiles/linux_openblas_arm.mk \
    && sed -i "s: -O1 : -O3 :g" makefiles/linux_openblas_arm.mk \
    && ./configure --mathlib=OPENBLAS_CLAPACK --shared --use-cuda=no \
    && make -j $(nproc) online2 lm rnnlm \
    && find /opt/kaldi -name "*.o" -exec rm {} \; \
    && cd /opt && git clone https://github.com/alphacep/vosk-api \
    && cd vosk-api/src \
    && KALDI_ROOT=/opt/kaldi make -j $(nproc) \
    && cd ../python \
    && python3 setup.py install \
    && rm -rf /opt/vosk-api/src/*.o \
    && rm -rf /opt/kaldi \
    && rm -rf /root/.cache \
    && rm -rf /var/lib/apt/lists/*
