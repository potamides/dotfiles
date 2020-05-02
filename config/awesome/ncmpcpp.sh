#!/bin/bash

MPD_HOST=${MPD_HOST-localhost}
MPD_PORT=${MPD_PORT-6600}
MPD_STREAM_PORT=${MPD_STREAM_PORT-8000}

ssh -nTNL $MPD_PORT:$MPD_HOST:$MPD_PORT -L $MPD_STREAM_PORT:$MPD_HOST:$MPD_STREAM_PORT NAS &
while true; do
    ffplay -flags low_delay -nodisp -loglevel quiet http://$MPD_HOST:$MPD_STREAM_PORT
    sleep 1
done &
ncmpcpp --host $MPD_HOST --port $MPD_PORT
