# Check nvidia registry for available suffixes.
ARG CUDA_TAG=11.3.1-devel-ubuntu20.04

FROM nvidia/cuda:$CUDA_TAG

ENV DEBIAN_FRONTEND=noninteractive

# Patch for broken keys
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	cmake \
	gcc \
	g++ \
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
	python3-websockets \
	python3-setuptools \
	zip \
	wget && \
	rm -rf /var/lib/apt/lists/*

RUN echo "[PREPARING_KALDI] >>>" && git clone -b vosk --single-branch https://github.com/alphacep/kaldi /opt/kaldi
RUN cd /opt/kaldi/tools && \
	sed -i 's:status=0:exit 0:g' extras/check_dependencies.sh && \
	sed -i 's:--enable-ngram-fsts:--enable-ngram-fsts --disable-bin:g' Makefile && \
	echo "[BUILDING OPENFST] >>>" && \
	make -j $(nproc) openfst cub
RUN cd /opt/kaldi/tools && echo \
	"[BUILDING OPENBLAS] >>>" && \
	extras/install_openblas_clapack.sh

RUN cd /opt/kaldi/src && \
	./configure --mathlib=OPENBLAS_CLAPACK --shared --use-cuda && \
	sed -i 's:-msse -msse2:-msse -msse2:g' kaldi.mk && \
	sed -i 's: -O1 : -O3 :g' kaldi.mk && \
	echo "[BUILDING KALDI] >>>" && \
	make -j $(nproc) online2 lm rnnlm cudafeat cudadecoder

RUN echo "[BUILDING VOSK] >>>" && \
	git clone https://github.com/alphacep/vosk-api /opt/vosk-api
RUN cd /opt/vosk-api/src && \
	KALDI_ROOT=/opt/kaldi HAVE_CUDA=1 make -j $(nproc) && \
	python3 -m pip install --upgrade pip setuptools wheel cython && \
    cd ../python && \
	python3 ./setup.py bdist_wheel && \
	cd ./dist && pip3 install vosk-*.whl

RUN echo "[CLEANING UP BUILD RESOURCES] >>>" && \
	rm -rf /opt/vosk-api/src/*.o && \
	rm -rf /opt/kaldi && \
	rm -rf /root/.cache && \
	rm -rf /var/lib/apt/lists/*
