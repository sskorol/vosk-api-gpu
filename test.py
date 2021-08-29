#!/usr/bin/env python3

import asyncio
import websockets
import sys

async def run_test(uri):
    async with websockets.connect(uri) as websocket:
        wf = open(sys.argv[1], "rb")
        while True:
            data = wf.read(16000)

            if len(data) == 0:
                break

            await websocket.send(data)
            print (await websocket.recv())

        await websocket.send('{"eof" : 1}')
        print (await websocket.recv())

asyncio.get_event_loop().run_until_complete(
    run_test('ws://localhost:2700'))
