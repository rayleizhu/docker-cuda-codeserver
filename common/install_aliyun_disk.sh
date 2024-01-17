#!/bin/bash

set -ex

install_() {
    curl -fsSL http://file.tickstep.com/apt/pgp | gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/tickstep-packages-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/tickstep-packages-archive-keyring.gpg arch=amd64,arm64] http://file.tickstep.com/apt aliyunpan main" | \
    tee /etc/apt/sources.list.d/tickstep-aliyunpan.list > /dev/null && \
    apt-get update && sudo apt-get install -y aliyunpan
}


##############################
case "$1" in 
  "0")
    ;;
  "1")
    echo "Install aliyunpan."
    install_
    ;;
  *)
    echo "Incorrect input arguments: $1. Skip installing aliyunpan."
    ;;
esac
##############################
