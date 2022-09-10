docker run -d --init \
  --restart unless-stopped \
  --name cuda-code-server \
  --gpus=all \
  --ipc=host \
  --user="$(id -u):$(id -g)" \
  --volume="${HOME}/codesever-home:/home/coder/" \
  -p 8443:8443 \
  cuda-code-server
