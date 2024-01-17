#!/bin/bash

set -ex

install_() {
    CODE_SERVER_VERSION=$1
    ARCH=$2
    cd /tmp &&\
    curl -fOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${ARCH}.deb && \
    dpkg -i ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb && rm ./code-server_${CODE_SERVER_VERSION}_${ARCH}.deb
}

##############################
case "$1" in 
  "None")
    echo "Skip installation of codeserver."
    ;;
  *)
    install_ $1 $2
    ;;
esac
##############################
