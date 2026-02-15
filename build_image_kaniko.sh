#!/usr/bin/env bash
set -euo pipefail

CUDA_VERSION=${CUDA_VERSION:-12.9.1} # https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md
OS=${OS:-ubuntu24.04}
CODE_SERVER_VERSION=${CODE_SERVER_VERSION:-4.109.2} # set "None" to disable codeserver installation; https://github.com/coder/code-server/releases
SET_APT_SOURCE=${SET_APT_SOURCE:-tuna} # set "tuna" for Mainland China users, "skip" otherwise
ENABLE_ALIYUN_DISK=${ENABLE_ALIYUN_DISK:-1} # useful for data/code sync, set 0 if you don't need it

IMAGE_NAME=${IMAGE_NAME:-cuda-codeserver-v2}
IMAGE_TAG=${IMAGE_TAG:-${OS}_cuda_${CUDA_VERSION}_codeserver_${CODE_SERVER_VERSION}}

KANIKO_EXECUTOR=${KANIKO_EXECUTOR:-kaniko-executor}
KANIKO_CONTEXT=${KANIKO_CONTEXT:-$PWD}
KANIKO_DOCKERFILE=${KANIKO_DOCKERFILE:-$PWD/Dockerfile}
DESTINATION_IMAGE=${DESTINATION_IMAGE:-}
KANIKO_NO_PUSH=${KANIKO_NO_PUSH:-1}
KANIKO_TAR_PATH=${KANIKO_TAR_PATH:-$PWD/build/${IMAGE_NAME}_${IMAGE_TAG}.tar}
CACHE=${CACHE:-false}
CACHE_REPO=${CACHE_REPO:-}

BUILD_DATE=$(date +"%Y-%m-%d")

if ! command -v "${KANIKO_EXECUTOR}" >/dev/null 2>&1; then
	echo "[error] cannot find ${KANIKO_EXECUTOR}" >&2
	exit 1
fi

mkdir -p "$(dirname "${KANIKO_TAR_PATH}")"

destination="${DESTINATION_IMAGE:-${IMAGE_NAME}:${IMAGE_TAG}}"

args=(
	"--context=${KANIKO_CONTEXT}"
	"--dockerfile=${KANIKO_DOCKERFILE}"
	"--destination=${destination}"
	"--build-arg=OS_RELEASE=${OS}"
	"--build-arg=CUDA_VERSION=${CUDA_VERSION}"
	"--build-arg=CODE_SERVER_VERSION=${CODE_SERVER_VERSION}"
	"--build-arg=SET_APT_SOURCE=${SET_APT_SOURCE}"
	"--build-arg=ENABLE_ALIYUN_DISK=${ENABLE_ALIYUN_DISK}"
	"--build-arg=BUILD_DATE=${BUILD_DATE}"
	"--build-arg=HTTP_PROXY=${HTTP_PROXY:-}"
	"--build-arg=HTTPS_PROXY=${HTTPS_PROXY:-}"
	"--build-arg=NO_PROXY=${NO_PROXY:-}"
)

if [[ "${CACHE}" == "true" ]]; then
	args+=("--cache=true")
	if [[ -n "${CACHE_REPO}" ]]; then
		args+=("--cache-repo=${CACHE_REPO}")
	fi
fi

if [[ "${KANIKO_NO_PUSH}" == "1" ]]; then
	args+=("--no-push" "--tar-path=${KANIKO_TAR_PATH}")
	echo "[build] kaniko no-push enabled, tar output: ${KANIKO_TAR_PATH}"
elif [[ -z "${DESTINATION_IMAGE}" ]]; then
	echo "[error] KANIKO_NO_PUSH=0 requires DESTINATION_IMAGE to be set" >&2
	exit 1
fi

echo "[build] engine=kaniko context=${KANIKO_CONTEXT} dockerfile=${KANIKO_DOCKERFILE} destination=${destination}"

export HTTP_PROXY=http://172.18.0.1:20172
export HTTPS_PROXY=http://172.18.0.1:20172

"${KANIKO_EXECUTOR}" "${args[@]}"