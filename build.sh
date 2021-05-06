#!/bin/bash

help()
{
    echo ""
    echo "Usage: $0 -m nano -i ml -t 0.3.27"
    echo -e "\t-m Jetson board model: nano or xavier (default: xavier)"
    echo -e "\t-i Image type: base or ml (default: base)"
    echo -e "\t-l L4T version (default: r32.5.0)"
    echo -e "\t-t Image tag (based on Vosk version: 0.3.27)"
    echo -e "\t-h Show help"
    exit 1
}

while getopts "m:t:i:l:h" opt
do
    case "$opt" in
      m) model="$OPTARG" ;;
      i) type="$OPTARG" ;;
      l) version="$OPTARG" ;;
      t) tag="$OPTARG" ;;
      h | ?) help ;;
    esac
done

if [[ -z "$model" ]]; then
    model="xavier"
fi

if [[ "$model" == "nano" ]]; then
    cpu="cortex-a57"
    arch="armv8-a"
elif [[ "$model" == "xavier" ]]; then
    cpu="cortex-a76"
    arch="armv8.2-a"
else
   echo "$model model is unsupported"
   help
fi

if [[ -z "$type" ]]; then
    type="base"
fi

if [[ "$type" != "base" ]] && [[ "$type" != "ml" ]]; then
    echo "$type image type is unsupported"
    help
fi

if [[ -z "$version" ]]; then
    version="r32.5.0"
fi

if [[ -z "$tag" ]]; then
    echo "Image tag is mandatory"
    help
fi

echo "BUILD ARGS: CPU=$cpu; ARCH=$arch; TYPE=$type; L4T_VERSION=$version; TAG=$tag-$model"

docker build -t sskorol/vosk-api:$tag-$model --build-arg CPU=$cpu --build-arg ARCH=$arch --build-arg TYPE=$type --build-arg L4T_VERSION=$version .
