FROM ubuntu:latest

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
	zsh \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libdbus-1-3 \
    && apt-get -qq clean

# to run Qt GUI apps
RUN apt install -y '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME /home/user

USER root

RUN sudo apt-get update -y
RUN sudo apt-get install ninja-build cmake wget -y

ARG QT_VERSION=5.15.2
ARG QT_INSTALLER_URL="https://mirrors.ocf.berkeley.edu/qt/archive/online_installers/3.2/qt-unified-linux-x64-3.2.1-2-online.run"
ARG QT_INSTALLER_SHA256="02a3445e5b8dab761946ad6f6f3d80ccf9a3246d689bcbec69112379dd523506"
# Use to pass URL with env exports file context with QT_CI_LOGIN & QT_CI_PASSWORD
ARG QT_CI_ENV_URL="http://host.docker.internal:8765/secrets.env"
ARG QT_ACC_ENV_URL=""

ENV DEBIAN_FRONTEND=noninteractive \
    QT_PATH=/opt/Qt \
    QT_BIN_PACKAGE=gcc_64
ENV QT_DESKTOP ${QT_PATH}/${QT_VERSION}/${QT_BIN_PACKAGE}
ENV PATH ${QT_DESKTOP}/bin:${QT_PATH}/Tools/CMake/bin:${QT_PATH}/Tools/Ninja:$PATH

COPY extract-qt-installer.sh /tmp/qt/

# Download & unpack Qt toolchains & clean
RUN echo "${QT_INSTALLER_SHA256} -" > sum.txt && curl -fLs "${QT_INSTALLER_URL}" | tee /tmp/qt/installer.run | sha256sum -c sum.txt \
    && [ -z "${QT_CI_ENV_URL}" ] && echo "" > /tmp/qt/secrets.env || curl "${QT_CI_ENV_URL}" > /tmp/qt/secrets.env && . /tmp/qt/secrets.env \
    && QT_CI_PACKAGES=qt.qt5.$(echo "${QT_VERSION}" | tr -d .).${QT_BIN_PACKAGE},qt.qt5.$(echo "${QT_VERSION}" | tr -d .).qtwebengine /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "${QT_PATH}" \
    && find "${QT_PATH}" -mindepth 1 -maxdepth 1 ! -name "${QT_VERSION}" ! -name "Tools" -exec echo 'Cleaning Qt SDK: {}' \; -exec rm -r '{}' \; \
    && rm -rf /tmp/qt /root/.local/share/Qt /root/.config/Qt

ARG DEV_NAME=neroshop-dev

# Add group & user + sudo
RUN groupadd -r ${DEV_NAME} && useradd --create-home --shell /bin/zsh --gid ${DEV_NAME} ${DEV_NAME}
RUN echo "${DEV_NAME}:123" | chpasswd
RUN usermod -aG sudo ${DEV_NAME}

USER ${DEV_NAME}
WORKDIR /home/${DEV_NAME}
ENV HOME /home/${DEV_NAME}

ENV DISPLAY=host.docker.internal:0