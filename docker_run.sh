#!/bin/bash

DOCKER_IMG=docker_qt_test
DOCKER_USER=app-dev
SRC_DIR=src/

docker run -ti --privileged --gpus all -v `pwd -W`/$SRC_DIR:/home/$DOCKER_USER/app-src/ $DOCKER_IMG:latest
