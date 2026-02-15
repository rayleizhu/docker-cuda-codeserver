#!/usr/bin/env bash
set -euo pipefail

# https://www.simpleapples.com/2019/04/18/building-docker-image-behind-proxy/
# if you have proxy for faster github access, uncomment below
# You may use mirrors if the pull of images is slow
# https://www.cnblogs.com/cao-lei/p/14448052.html

CUDA_VERSION=${CUDA_VERSION:-12.9.1} # https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md
OS=${OS:-ubuntu24.04}
CODE_SERVER_VERSION=${CODE_SERVER_VERSION:-4.109.2} # set "None" to disable codeserver installation; https://github.com/coder/code-server/releases
SET_APT_SOURCE=${SET_APT_SOURCE:-tuna} # set "tuna" for Mainland China users, "skip" otherwise
ENABLE_ALIYUN_DISK=${ENABLE_ALIYUN_DISK:-1} # useful for data/code sync, set 0 if you don't need it

IMAGE_NAME=${IMAGE_NAME:-cuda-codeserver-v2}
IMAGE_TAG=${IMAGE_TAG:-${OS}_cuda_${CUDA_VERSION}_codeserver_${CODE_SERVER_VERSION}}

BUILD_DATE=$(date +"%Y-%m-%d")

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" . \
	--build-arg OS_RELEASE="${OS}" \
	--build-arg CUDA_VERSION="${CUDA_VERSION}" \
	--build-arg CODE_SERVER_VERSION="${CODE_SERVER_VERSION}" \
	--build-arg SET_APT_SOURCE="${SET_APT_SOURCE}" \
	--build-arg ENABLE_ALIYUN_DISK="${ENABLE_ALIYUN_DISK}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--network host \
	--build-arg HTTP_PROXY="${HTTP_PROXY:-}" \
	--build-arg HTTPS_PROXY="${HTTPS_PROXY:-}" \
	--build-arg NO_PROXY="${NO_PROXY:-}"
