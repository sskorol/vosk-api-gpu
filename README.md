## Vosk API - Docker/GPU

[Vosk](https://github.com/alphacep/vosk-api) docker images with GPU for Jetson Nano / Xavier NX boards and PCs with NVIDIA cards.

### Usage

Pull an existing [image](https://hub.docker.com/r/sskorol/vosk-api) with a required tag.

```shell
docker pull sskorol/vosk-api:$TAG
```

Use it as a baseline in your app's Dockerfile:

```shell
FROM sskorol/vosk-api:$TAG
```

### Build prerequisites

- You have to enable [nvidia runtime](https://github.com/dusty-nv/jetson-containers#docker-default-runtime) before building the images.
- In the case of Jetson boards, your JetPack should match at least 32.5 version (0.3.32 images were built against 32.6.1).
- For PCs make sure you met the following [prerequisites](https://medium.com/geekculture/installing-cudnn-and-cuda-toolkit-on-ubuntu-20-04-for-machine-learning-tasks-f41985fcf9b2).

### Building

Clone sources and check a build file help:

```shell
git clone https://github.com/sskorol/vosk-api-gpu.git
cd vosk-api-gpu
```

#### Jetson boards

Run a build script with the required args depending on your platform, e.g.:

```shell
./build.sh -m nano -i ml -t 0.3.37
```

You can check the available NVIDIA base image tags [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base) and [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-ml). 

#### PCs

To build images for PC, use the following script:

```shell
./build-pc.sh -c 11.3.0-devel-ubuntu20.04 -t 0.3.37
```

Here, you have to provide a base cuda image tag and the output container's tag. You can read more by running the script with `-h` flag.

This script will build 2 images: base and a sample Vosk server.

### Running

- As you can reuse a `docker-compose.yml` both for Jetson boards and PCs, it's required to manually set the image tag. Either modify a compose file directly or create a `.env` file with a `TAG=X.X.X` version.
- To start a newly built container, run the following command:

```shell
docker-compose up -d
```

Note that you have to download and extract a required [model](https://alphacephei.com/vosk/models) into `./model` folder first.

### Important notes

- Jetson Nano won't work with the latest large model due to high memory requirements (at least 8Gb RAM).
- Jetson Xavier **will** work with the latest large model if you remove `rnnlm` folder from `model`.
- Make sure you have at least Docker (20.10.6) and Compose (1.29.1) versions.
- Your host's CUDA version must match the container's as they share the same runtime. Jetson images were built with CUDA 10.1. As per the desktop version: CUDA 11.3.0 was used.
- If you plan to use `rnnlm`, make sure you allocated at least 12Gb of RAM to your Docker instance (16Gb is optimal).

### Testing

First, install the required dependencies:

```shell
python3 -m venv .venv
source .venv/bin/activate
pip3 install pip --upgrade
pip3 install websockets asyncio
```

Now you can perform a quick test for the RU model with the following script:

```shell
./test.py weather.wav
```

Use your own recording to test it against any other language. 

### Apple M1 Support

To build images (w/o GPU) for Apple M1, use the following script:

```shell
./build-m1.sh -t 0.3.37
```

To build Kaldi and Vosk API locally (w/o Docker), use the following script (thanks to @aivoicesystems):

```shell
./build-m1-local.sh
```
