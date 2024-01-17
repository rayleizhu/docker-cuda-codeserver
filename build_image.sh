# https://www.simpleapples.com/2019/04/18/building-docker-image-behind-proxy/
# if you have proxy for faster github access, uncomment below
# You may use mirrors if the pull of images is slow
# https://www.cnblogs.com/cao-lei/p/14448052.html

CUDA_VERSION=12.1.1 # https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md
OS=ubuntu20.04
CODE_SERVER_VERSION=4.20.0 # set "None" to disable codeserver installation
SET_APT_SOURCE=tuna # set "tuna" for Mainland China users, "skip" otherwise
ENABLE_ALIYUN_DISK=1 # useful for data/code sync, set 0 if you don't need it

IMAGE_TAG=${OS}_cuda_${CUDA_VERSION}_codeserver_${CODE_SERVER_VERSION}

# curl google.com && \
docker build -t cuda-codeserver-v2:${IMAGE_TAG} . \
	--build-arg OS_RELEASE=${OS} \
	--build-arg CUDA_VERSION=${CUDA_VERSION} \
	--build-arg CODE_SERVER_VERSION=${CODE_SERVER_VERSION} \
	--build-arg SET_APT_SOURCE=${SET_APT_SOURCE} \
	--build-arg ENABLE_ALIYUN_DISK=${ENABLE_ALIYUN_DISK} \
	--build-arg BUILD_DATE=$(date +"%Y-%m-%d") \
	--build-arg HTTP_PROXY=http://172.17.0.1:7890 \
	--build-arg HTTPS_PROXY=http://172.17.0.1:7890 \
	--no-cache \
	--network host 
