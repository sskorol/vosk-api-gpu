## Vosk API - Docker/GPU

Docker images with GPU for Jetson Nano / Xavier NX boards and PCs with NVIDIA cards.

### Usage

Pull an existing [image](https://hub.docker.com/r/sskorol/vosk-api) with a required tag.

```shell script
docker pull sskorol/vosk-api:$TAG
```

Use it as a baseline in your app's Dockerfile:

```shell script
FROM sskorol/vosk-api:$TAG
```

### Build prerequisites

You have to enable [nvidia runtime](https://github.com/dusty-nv/jetson-containers#docker-default-runtime) before building the images.

In the case of Jetson boars, your JetPack should match at least 32.5 version (0.3.30 images were built against 32.6.1).

For PCs make sure you met the following [prerequisites](https://medium.com/geekculture/installing-cudnn-and-cuda-toolkit-on-ubuntu-20-04-for-machine-learning-tasks-f41985fcf9b2).

### Building

Clone sources and check a build file help:

```shell script
git clone https://github.com/sskorol/vosk-api-gpu.git
cd vosk-api-gpu
./build.sh -h
```

Then run it with required args depending on your platform, e.g.:

```shell script
./build.sh -m nano -i ml -t 0.3.30
```

You can check the available NVIDIA base image tags [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base) and [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-ml). 

To build images for PC, use the following script:

```shell script
./build-pc.sh -c 11.3.0-devel-ubuntu20.04 -t 0.3.30
```

Here, you have to provide a base cuda image tag and the ouput container's tag. You can read more by running the script wiht `-h` flag.

This script will build 2 images: base and a sample Vosk server.

To start a newly built container, run the following command:

```shell script
docker-compose up -d
```

Note that you have to download and extract a required [model](https://alphacephei.com/vosk/models) into `./model` folder.

Jetson Nano won't work with latest large model due to high memory requirements (at least 8Gb RAM).

Jetson Xavier **will** work with latest large model if you remove `rnnlm` folder from `model`.

Also make sure you have at least Docker (20.10.6) and Compose (1.29.1) versions.

Your host's CUDA version should match the container's. Jetson images were built with CUDA 10.1. As per the desktop version: CUDA 11.3.0 was used.

### Testing

First, install the required dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip3 install pip --upgrade
pip3 install websockets asyncio
```

Now you can perform a quick test for RU model with the following script:

```bash
./test.py weather.wav
```
