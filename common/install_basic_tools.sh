#!/bin/bash

set -ex

set_apt_source_tuna() {
  # Backup & Replace official sources with TUNA mirror (works for any ubuntu release)
  cp /etc/apt/sources.list /etc/apt/sources.list.bak &&\
  sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list &&\
  sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
}

install_base() {
  # Ensure ca-certificates is installed for https sources
  # https://devicetests.com/accept-microsoft-eula-ubuntu
  apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  procps \
  openssh-client \
  openssh-server \
  vim \
  lsb-release \
  tmux \
  nodejs \
  dvipng texlive-latex-extra texlive-fonts-recommended cm-super \
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



  