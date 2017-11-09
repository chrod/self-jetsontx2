# Dockerfile, watson-intu/Self build using raspbian (arm64)
# Usage: docker build -f Dockerfile -t openhorizon/cogwerx-aarch64-tx2-self:<version> .

FROM debian:jessie
MAINTAINER dyec@us.ibm.com

# Required for web UI
EXPOSE 9443

RUN apt-get update && apt-get install -y apt-utils
RUN apt-get install -y \
  build-essential \
  cmake \
  curl \
  git \
  libpng12-dev \
  usbutils \
  gettext \
  unzip \
  wget

## Grab self code
RUN mkdir -p /root/src/chrod
RUN git clone --branch edge --recursive https://github.com/chrod/self.git /root/src/chrod/self

# Install pip, python-dev libssl-dev, opencv-dev, py-opencv, LXDE & deps
RUN apt-get install -y libssl-dev \
  python-pip \
  python2.7-dev \
  libopencv-dev \
  python-opencv \
  libboost-all-dev

# Pip install python deps (qibuild, numpy)
RUN pip install --upgrade pip
RUN pip install qibuild numpy

# Build Self (default config)
WORKDIR /root/src/chrod/self
COPY tc_install.sh /root/src/chrod/self/scripts/tc_install.sh
RUN mkdir -p /root/src/chrod/self/packages
RUN ./scripts/build_linux.sh

## Self Setup
## Edit ALSA config (set sound card to #3: USB card, after webcam (#2))
COPY alsa.conf /usr/share/alsa/alsa.conf

##############
## apt-get install -y vim wget alsa-utils alsaplayer alsaplayer-text
## Configure Self with your own creds:
# cd <self config dir, containing bootstrap.json>
# copy in bootstrap.json file

## Run:
# docker run -it --rm --privileged -p 9443:9443 -v $PWD:/configs openhorizon/cogwerx-aarch64-tx2-self:<version> /bin/bash -c "ln -s -f /configs/bootstrap.json bin/linux/etc/shared/; ln -s -f /configs/default.json bin/linux/etc/shared/; ln -s -f /configs/alsa.conf /usr/share/alsa/; bin/linux/run_self.sh"
