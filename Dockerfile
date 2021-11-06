# Check nvidia registry for available suffixes. 
ARG TYPE=base
ARG L4T_VERSION=r32.6.1

FROM nvcr.io/nvidia/l4t-$TYPE:$L4T_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	cmake \
	gcc \
	gcc-8 \
	g++ \
	g++-8 \
	git \
	libtool \
	make \
	nano \
	pkg-config \
	python3 \
	python3-pip \
	python3-wheel \
	python3-cffi \
	python3-dev \
	python3-setuptools \
	zip \
	wget && \ 
	rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8

ARG ARCH=armv8.2-a
ARG CPU=cortex-a76
ARG TARGET=ARMV8
ARG VOSK_ARCHITECTURE=aarch64
ARG VOSK_SOURCE=/opt/vosk-api

RUN echo "[PREPARING_KALDI] >>>" && git clone -b vosk --single-branch https://github.com/alphacep/kaldi /opt/kaldi
RUN cd /opt/kaldi/tools && \
	sed -i 's:status=0:exit 0:g' extras/check_dependencies.sh && \
	sed -i "s:CXXFLAGS = -g -O3 -msse -msse2:CXXFLAGS = -g -O3 -march=$ARCH -mcpu=$CPU:g" Makefile && \
	sed -i 's:--enable-ngram-fsts:--enable-ngram-fsts --disable-bin:g' Makefile && \
	echo "[BUILDING OPENFST] >>>" && \
	make -j $(nproc) openfst cub
RUN cd /opt/kaldi/tools && echo \
	"[BUILDING OPENBLAS] >>>" && \
	sed -i "s:DYNAMIC_ARCH=1 TARGET=NEHALEM:TARGET=$TARGET:g" extras/install_openblas_clapack.sh && \
	extras/install_openblas_clapack.sh

RUN cd /opt/kaldi/src && \
	./configure --mathlib=OPENBLAS_CLAPACK --shared --use-cuda && \
	sed -i "s: -O1 : -O3 -march=$ARCH :g" kaldi.mk && \
	echo "[BUILDING KALDI] >>>" && \
	make -j $(nproc) online2 lm rnnlm

RUN echo "[BUILDING VOSK] >>>" && \
	git clone https://github.com/alphacep/vosk-api.git /opt/vosk-api
RUN cd /opt/vosk-api/src && \
	KALDI_ROOT=/opt/kaldi HAVE_CUDA=1 make -j $(nproc) && \
	python3 -m pip install --upgrade pip setuptools wheel cython && \
        cd /opt/vosk-api/python && \
	python3 ./setup.py install

RUN echo "[CLEANING UP BUILD RESOURCES] >>>" && \
	rm -rf /opt/vosk-api/src/*.o && \
	rm -rf /opt/kaldi && \
	rm -rf /root/.cache && \
	rm -rf /var/lib/apt/lists/*
