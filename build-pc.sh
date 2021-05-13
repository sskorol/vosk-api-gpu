#!/bin/bash

docker build -f Dockerfile.pc -t sskorol/vosk-api:0.3.27-pc .
docker build -f Dockerfile.server -t sskorol/vosk-server:0.3.27-pc .
