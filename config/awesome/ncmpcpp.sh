#!/bin/bash

MPD_HOST=${MPD_HOST-localhost}
MPD_PORT=${MPD_PORT-6600}
MPD_STREAM_PORT=${MPD_STREAM_PORT-8000}

ssh -nTNL $MPD_PORT:$MPD_HOST:$MPD_PORT -L $MPD_STREAM_PORT:$MPD_HOST:$MPD_STREAM_PORT NAS &
while true; do
    if mpv --profile=low-latency --no-terminal http://$MPD_HOST:$MPD_STREAM_PORT; then
        break
    else
        sleep 1
    fi
done &
ncmpcpp --host $MPD_HOST --port $MPD_PORT
