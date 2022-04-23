#!/usr/bin/env bash
prog=$(basename "$0")

BUILD_IN='/tmp'
if [ $# -gt 0 ]; then
  BUILD_IN="$1"
  shift
fi

case $(uname -s) in
Darwin) ;;

*)
  echo "${prog}: this script is designed for MacOS (Darwin)" >&2
  exit 1
  ;;
esac

# Check that all the required tools are available
#
# Other things may also be required (g++/clang etc)
# but autoconf/configure should detect this
#
missing=
for tool in aclocal autoreconf cmake diskutil git make sysctl; do
  if ! which ${tool} >/dev/null; then
    missing="${missing} ${tool}"
  fi
done
if [ -n "${missing}" ]; then
  echo "${prog}: the following tools which are needed for the build are missing:" >&2
  for tool in ${missing}; do
    echo "  ${tool}" >&2
  done
  exit 1
fi

BUILD_ROOT="${BUILD_IN}/vosk-build"
rm -fr "${BUILD_ROOT}"
if ! mkdir -p "${BUILD_ROOT}"; then
  echo "${prog}: can't create build directory ${BUILD_ROOT}" >&2
  exit 1
fi

nproc=$(sysctl -n hw.physicalcpu)

cd "${BUILD_ROOT}"

exec 3>&1

say() {
  echo "$@"
  echo "$@" >&3
}

(
  set -e

  say 'Cloning kaldi...'
  rm -fr kaldi
  git clone -b vosk --single-branch https://github.com/alphacep/kaldi

  say 'Cloning tools/OpenBLAS...'
  cd kaldi/tools
  git clone -b v0.3.13 --single-branch https://github.com/xianyi/OpenBLAS

  say 'Compiling tools/OpenBLAS...'
  make -C OpenBLAS ONLY_CBLAS=1 DYNAMIC_ARCH=1 TARGET=NEHALEM USE_LOCKING=1 USE_THREAD=0 all
  make -C OpenBLAS PREFIX="$(pwd)"/OpenBLAS/install install
  cd ../..

  say 'Cloning tools/clapack...'
  cd kaldi/tools
  git clone -b v3.2.1 --single-branch https://github.com/alphacep/clapack _clapack

  say 'Compiling tools/clapack...'
  mkdir -p _clapack/BUILD
  cd _clapack/BUILD
  cmake ..
  cat <<-EOF >/tmp/patch
  /^#include "blaswrap.h"/a\\
  #include <stdio.h>
EOF
  sed -f /tmp/patch -i .bak ../BLAS/SRC/xerbla.c
  make -j ${nproc}

  say 'Installing in OpenBLAS...'
  find . -name '*.a' -exec cp {} ../../OpenBLAS/install/lib \;
  cd ../../../..

  say 'Cloning tools/openfst...'
  cd kaldi/tools
  git clone --single-branch https://github.com/alphacep/openfst openfst

  say 'Compiling tools/openfst...'
  cd openfst
  autoreconf -i
  CFLAGS='-g -O3' ./configure --prefix "$(pwd)" --enable-static --enable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic --disable-bin
  make -j ${nproc}
  make install
  cd ../../..

  say 'Compiling kaldi...'
  cd kaldi/src
  ./configure --mathlib=OPENBLAS_CLAPACK --shared --use-cuda=no
  #sed -i .bak 's:-msse -msse2:-msse -msse2:g' kaldi.mk
  sed -i .bak 's: -O1 : -O3 :g' kaldi.mk
  make -j ${nproc} online2 lm rnnlm
  cd ../..

  say 'Cleaning up'
  cd kaldi
  find . -name '*.o' -exec rm {} \;
  cd ..

  say 'Cloning vosk-api'
  rm -fr vosk-api
  git clone https://github.com/alphacep/vosk-api

  say 'Compiling vosk-api'
  cd vosk-api/src
  sed -i .bak 's/ -latomic//' Makefile
  EXT=dyld KALDI_ROOT=../../kaldi make -j ${nproc}
  cp libvosk.dyld ../..

  say 'Building vosk-api python module'
  cd ../python
  python3 setup.py install

) >build.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build failed"
  echo "Here are the last few lines of the log file:"
  tail -10 build.log
  echo "Full log is in $(pwd)/build.log"
  exit 1
fi

rm -fr kaldi vosk-api build.log

echo 'Build successful'
dylib="$(pwd)/libvosk.dyld"
echo "Shared library available in ${dylib}"
ls -l "${dylib}"
file "${dylib}"
otool -L "${dylib}"

exit 0
