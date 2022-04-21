#!/bin/bash

help()
{
    echo "Usage: $0 -t 0.3.37"
    echo -e "\t-t Image tag (based on Vosk version: 0.3.37)"
    echo -e "\t-h Show help"
    exit 1
}

while getopts "t:h" opt
do
    case "$opt" in
      t) tag="$OPTARG" ;;
      h | ?) help ;;
    esac
done

if [[ -z "$tag" ]]; then
    echo "Image tag is mandatory"
    help
fi

echo "ARGS: TAG=$tag"
BUILD_TAG="$tag-m1"

docker build -f Dockerfile.m1 --no-cache -t sskorol/vosk-api:$BUILD_TAG .
docker build -f Dockerfile.m1.server --no-cache -t sskorol/vosk-server:$BUILD_TAG --build-arg TAG=$BUILD_TAG .
