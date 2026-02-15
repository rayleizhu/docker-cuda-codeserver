docker run -d --init \
  --restart unless-stopped \
  --name cuda-codeserver-v2 \
  --gpus=all \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="${HOME}/codesever-home:/home/coder/" \
  -p 8443:8443 \
  -p 8822:22 \
  cuda-codeserver-v2:ubuntu20.04_cuda_12.1.1_codeserver_4.20.0
