#!/bin/bash

python -m http.server 8765 &
SERVER_PID=$!

docker build -t docker_qt_test .

kill $SERVER_PID