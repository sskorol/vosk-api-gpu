#!/bin/bash

TAG=0.3.37
CUDA_IMAGE=11.3.1-devel-ubuntu20.04
MODEL_NAME=vosk-model-ru-0.22
MODEL_ARCHIVE="$MODEL.zip"

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
cd ../ && wget "https://alphacephei.com/vosk/models/$MODEL_ARCHIVE" \
  && unzip MODEL_ARCHIVE \
  && rm -f MODEL_ARCHIVE \
  && mv $MODEL_NAME model \
  && sed -i '1d' ./model/conf/model.conf \
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

# Build Vosk API and server
cd pc && ./build.sh -c $CUDA_IMAGE -t $TAG
