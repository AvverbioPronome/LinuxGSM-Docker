#
# LinuxGSM Dockerfile
#
# https://github.com/GameServerManagers/LinuxGSM-Docker
#

FROM ubuntu:18.04
LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y locales \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

## Base System
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y iproute2\
                       curl \
                       wget \
                       file \
                       bzip2 \
                       gzip \
                       unzip \
                       bsdmainutils \
                       python3 \
                       util-linux \
                       binutils \
                       bc \
                       jq \
                       ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


## user config
RUN groupadd -g 750 -o linuxgsm \
 && adduser --uid 750 --disabled-password --gecos "" --ingroup linuxgsm linuxgsm \
 && usermod -G tty linuxgsm \
 && chown -R linuxgsm:linuxgsm /home/linuxgsm/ \
 && chmod 755 /home/linuxgsm

# Switch to the user linuxgsm
USER linuxgsm
WORKDIR /home/linuxgsm

## linuxgsm.sh
RUN wget https://linuxgsm.com/dl/linuxgsm.sh -O ~/linuxgsm.sh \
 && chmod +x ~/linuxgsm.sh

VOLUME [ "/home/linuxgsm" ] # define volume _after_ download.

# need use xterm for LinuxGSM
ENV TERM=xterm

## Docker Details
ENV PATH=$PATH:/home/linuxgsm

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash","/entrypoint.sh" ]
