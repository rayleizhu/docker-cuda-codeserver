# https://www.simpleapples.com/2019/04/18/building-docker-image-behind-proxy/
# if you have proxy for faster github access
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890

docker build -t cuda-code-server:latest . \
	--build-arg CUDA_VERSION=11.3.0 \
       	--build-arg OS_RELEASE=ubuntu20.04 \
	--build-arg CODE_SERVER_VERSION=4.7.0 \
	--build-arg BUILD_DATE=$(date +"%Y-%m-%d") \
	--no-cache \
	--network host 

