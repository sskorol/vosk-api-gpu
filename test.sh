#!/bin/bash

TAG=${1:-latest}
WAV=${2:-en.wav}

echo "TAG=$TAG" > .env \
  && docker-compose up -d \
  && python3 -m venv .venv \
  && source .venv/bin/activate \
  && pip3 install pip --upgrade \
  && pip3 install asyncio websockets \
  && sleep 10 \
  && ./test.py "$WAV" \
  && deactivate \
  && docker-compose down
