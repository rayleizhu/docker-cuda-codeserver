# https://www.simpleapples.com/2019/04/18/building-docker-image-behind-proxy/
# if you have proxy for faster github access
# export https_proxy=127.0.0.1:7890
# export http_proxy=127.0.0.1:7890
# export HTTPS_PROXY=127.0.0.1:7890
# export HTTP_PROXY=127.0.0.1:7890

# You may use mirrors if the pull of images is slow
# https://www.cnblogs.com/cao-lei/p/14448052.html

CUDA_VERSION=11.8.0 # https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md
OS=ubuntu20.04
CODE_SERVER_VERSION=4.19.1

# curl google.com && \
docker build -t cuda-code-server:${OS}_cuda_${CUDA_VERSION}_codeserver_${CODE_SERVER_VERSION} . \
	--build-arg CUDA_VERSION=${CUDA_VERSION} \
	--build-arg OS_RELEASE=${OS} \
	--build-arg CODE_SERVER_VERSION=4.19.1 \
	--build-arg BUILD_DATE=$(date +"%Y-%m-%d") \
	--no-cache \
	--network host 

