#!/bin/bash

help()
{
    echo ""
    nvcc -V
    echo ""
    echo "Usage: $0 -c 11.3.1-devel-ubuntu20.04 -t 0.3.37 -m vosk-model-en-us-0.22"
    echo -e "\t-c CUDA image version, e.g. 11.3.1-devel-ubuntu20.04"
    echo -e "\t-t Image tag, based on Vosk version, e.g. 0.3.37"
    echo -e "\t-m Model name, based on https://alphacephei.com/vosk/models, e.g. vosk-model-en-us-0.22"
    echo -e "\t-p If set, patch the model for GPU support (e.g. EN model is already patched, RU is not)"
    echo -e "\t-h Show help"
    exit 1
}

while getopts "c:t:m:ph" opt
do
    case "$opt" in
      c) cuda="$OPTARG" ;;
      t) tag="$OPTARG" ;;
      m) model="$OPTARG" ;;
      p) patch='true' ;;
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

if [[ -z "$model" ]]; then
    echo "Model name is mandatory"
    help
fi

if [[ -z "$patch" ]]; then
    patch='false'
fi

echo "ARGS: CUDA=$cuda; TAG=$tag; MODEL=$model"
model_archive="$model.zip"

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Make nvidia-runtime a default one
sudo tee /etc/docker/daemon.json /dev/null <<EOT
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOT

# Apply Docker runtime changes
sudo systemctl restart docker

# Patch model
cd ../ && wget "https://alphacephei.com/vosk/models/$model_archive" \
  && unzip "$model_archive" \
  && rm -f "$model_archive" \
  && mv "$model" model

if [[ "$patch" == 'true' ]]; then
  sed -i '1d' ./model/conf/model.conf \
  && cat <<EOT >> ./model/conf/ivector.conf
--cmvn-config=model/ivector/online_cmvn.conf
--ivector-period=10
--splice-config=model/ivector/splice.conf
--lda-matrix=model/ivector/final.mat
--global-cmvn-stats=model/ivector/global_cmvn.stats
--diag-ubm=model/ivector/final.dubm
--ivector-extractor=model/ivector/final.ie
--num-gselect=5
--min-post=0.025
--posterior-scale=0.1
EOT
fi

# Build Vosk API and server
cd pc && ./build.sh -c "$cuda" -t "$tag"
