#
# LinuxGSM Dockerfile
#
# https://github.com/GameServerManagers/LinuxGSM-Docker
#

FROM debian:buster-slim
LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update \
 && apt-get install -y locales \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

## Base System
RUN dpkg --add-architecture i386\
 && apt-get update -y\
 && apt-get install -y sudo tmux bash\
                       curl wget file tar bzip2 gzip unzip\
                       bsdmainutils python3 util-linux\
                       ca-certificates binutils bc jq\
                       iproute2 procps\
 && apt-get clean\
 && rm -rf /var/lib/apt/lists/*

VOLUME ["/usr"] # we want persistence for GAMESERVER dependencies
# or maybe we don't, and this image is supposed to be used as a base image, for childs like:
# FROM this-image
# RUN ["./linuxgsm.sh", "q2server"]
# RUN ["./q2server", "install"]

## user config
RUN groupadd -g 750 -o linuxgsm\
 && adduser --uid 750 --disabled-password --gecos "" --ingroup linuxgsm linuxgsm\
 && usermod -G tty linuxgsm\
 && chown -R linuxgsm:linuxgsm /home/linuxgsm/\
 && chmod 755 /home/linuxgsm

# we give sudo powers with no password to this user. it's a docker
# container. as long as you behave and DON'T RUN THIS AS --privileged,
# it's all fine
RUN echo "linuxgsm ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to the user linuxgsm
USER linuxgsm
WORKDIR /home/linuxgsm

## linuxgsm.sh
RUN wget https://linuxgsm.com/dl/linuxgsm.sh -O ~/linuxgsm.sh \
 && chmod +x ~/linuxgsm.sh

VOLUME ["/home/linuxgsm"]

# need use xterm for LinuxGSM
ENV TERM=xterm

## Docker Details
ENV PATH=$PATH:/home/linuxgsm

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh" ]
