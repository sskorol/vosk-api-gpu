### Vosk API - Docker/GPU

Docker images for Jetson Nano / Xavier NX boards with CUDA support.

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
git clone https://github.com/sskorol/vosk-api-jetson.git
cd vosk-api-jetson
./build.sh -h
```

Then run it with required args depending on your platform, e.g.:

```shell script
./build.sh -m nano -i ml -t 0.3.27
```

You can check the available NVIDIA base image tags [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base) and [here](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-ml). 
