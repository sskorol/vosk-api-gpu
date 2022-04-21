#!/bin/bash

help()
{
    echo ""
    echo "$(nvcc -V)"
    echo ""
    echo "Usage: $0 -c 11.3.0-devel-ubuntu20.04 -t 0.3.37"
    echo -e "\t-c CUDA image version"
    echo -e "\t-t Image tag (based on Vosk version: 0.3.37)"
    echo -e "\t-h Show help"
    exit 1
}

while getopts "c:t:h" opt
do
    case "$opt" in
      c) cuda="$OPTARG" ;;
      t) tag="$OPTARG" ;;
      h | ?) help ;;
    esac
done

if [[ -z "$cuda" ]]; then
    echo "CUDA version is mandatory"
    help
fi

if [[ -z "$tag" ]]; then
    echo "Image tag is mandatory"
    help
fi

echo "ARGS: CUDA=$cuda; TAG=$tag"

docker build -f Dockerfile.pc --no-cache -t sskorol/vosk-api:$tag-pc --build-arg CUDA_TAG=$cuda .
docker build -f Dockerfile.server --no-cache -t sskorol/vosk-server:$tag-pc --build-arg TAG=$tag-pc .
