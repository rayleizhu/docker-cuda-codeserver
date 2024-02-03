#!/bin/bash

set -ex

set_apt_source_tuna() {
  mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
  echo 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list && \
  echo '# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list && \
  echo 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list &&\
  echo '# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list &&\
  echo 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list &&\
  echo '# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list &&\
  echo 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list &&\
  echo '# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
}

install_base() {
  # https://devicetests.com/accept-microsoft-eula-ubuntu
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  dumb-init \
  htop \
  sudo \
  git \
  git-lfs \
  net-tools \
  ttf-mscorefonts-installer \
  wget \
  bzip2 \
  libx11-6 \
  locales \
  man \
  nano \
  git \
  procps \
  openssh-client \
  vim.tiny \
  lsb-release \
  python \
  python3-pip \
  python3-opencv \
  tmux \
  dvipng texlive-latex-extra texlive-fonts-recommended cm-super \
  nodejs \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
}


##############################
case "$1" in 
  "skip")
    ;;
  "tuna")
    echo "Use tuna mirror for apt."
    set_apt_source_tuna
    ;;
  *)
    echo "Incorrect input arguments: $1. Skip setting apt source."
    ;;
esac

install_base
##############################



  