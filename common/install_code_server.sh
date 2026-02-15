#!/bin/bash

set -ex

install_() {
    CODE_SERVER_VERSION=$1
    ARCH=$2
    
    echo "Installing code-server v${CODE_SERVER_VERSION} for ${ARCH}..."
    
    # Validating architecture mapping if needed, but current code-server releases 
    # use dpkg naming standard (amd64, arm64) which matches docker's TARGETARCH.
    
    TEMP_DEB="$(mktemp).deb"
    curl -fsSL -o "$TEMP_DEB" "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_${ARCH}.deb" && \
    dpkg -i "$TEMP_DEB" && \
    rm -f "$TEMP_DEB"
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
