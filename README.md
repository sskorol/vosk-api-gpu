### Vosk API - Docker/GPU

Docker images with GPU for Jetson Nano / Xavier NX boards and PCs with NVIDIA cards.

#### Usage

Pull an existing [image](https://hub.docker.com/r/sskorol/vosk-api) with a required tag.

```shell script
docker pull sskorol/vosk-api:$TAG
```

Use it as a baseline in your app's Dockerfile:

```shell script
FROM sskorol/vosk-api:$TAG
```

#### Building

Clone sources and check a build file help:

```shell script
git clone https://github.com/sskorol/vosk-api-gpu.git
cd vosk-api-gpu
./build.sh -h
```

Then run it with required args depending on your platform, e.g.:

```shell script
./build.sh -m nano -i ml -t 0.3.27
```

You can check the available NVIDIA base image tags [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base) and [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-ml). 

To build images for PC, use the following script:

```shell script
./build-pc.sh
```

It'll build 2 images: base and a sample Vosk server.

To start a newly built container, run the following command:

```shell script
docker-compose up -d
```

Note that you have to download and extract a required [model](https://alphacephei.com/vosk/models) into `./model` folder.

Also make sure you have at least Docker (20.10.6) and Compose (1.29.1) versions.
