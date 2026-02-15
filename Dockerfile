ARG CUDA_VERSION=11.3.0
ARG OS_RELEASE=ubuntu20.04
#FROM nvidia/cuda:11.1-base-ubuntu20.04
FROM gcr.io/kaniko-project/executor:v1.24.0-debug AS kaniko
FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-devel-${OS_RELEASE}


# ARG SET_APT_SOURCE=skip -> use official apt source
ARG SET_APT_SOURCE=tuna
ARG ENABLE_ALIYUN_DISK=1
# ARG CODE_SERVER_VERSION=None -> disable installation of codeserver
ARG CODE_SERVER_VERSION=4.7.0

# Automatic platform ARGs in the global scope
ARG TARGETARCH

# Install dependencies
COPY common/install_basic_tools.sh install_basic_tools.sh
RUN bash ./install_basic_tools.sh ${SET_APT_SOURCE} && rm install_basic_tools.sh

# set locale
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

# Create a non-root user & the project directory
ENV PROJECTS_ROOT=/home/coder/projects
RUN adduser --disabled-password --gecos '' --shell /bin/bash coder \
  && mkdir -p ${PROJECTS_ROOT} \
  && chown -R coder:coder ${PROJECTS_ROOT} \
  && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-coder

# Install fixuid
# https://www.kuangstudy.com/bbs/1455772174060093441
RUN curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-${TARGETARCH:-amd64}.tar.gz" | tar -C /usr/local/bin -xzf - && \
  chown root:root /usr/local/bin/fixuid && \
  chmod 4755 /usr/local/bin/fixuid && \
  mkdir -p /etc/fixuid && \
  printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

# Install code-server
COPY common/install_code_server.sh install_code_server.sh 
RUN bash ./install_code_server.sh ${CODE_SERVER_VERSION} ${TARGETARCH:-amd64} && rm install_code_server.sh

# copy entrypoint script
COPY common/entrypoint.sh /usr/bin/entrypoint.sh

# install aliyunpan
COPY common/install_aliyun_disk.sh install_aliyun_disk.sh
RUN bash ./install_aliyun_disk.sh ${ENABLE_ALIYUN_DISK} && rm install_aliyun_disk.sh

# Add Kaniko executor for daemonless image build in low-privilege environments
COPY --from=kaniko /kaniko/executor /usr/local/bin/kaniko-executor
COPY --from=kaniko /kaniko/ssl/certs/ /kaniko/ssl/certs/
RUN chmod +x /usr/local/bin/kaniko-executor \
  && mkdir -p /kaniko/.docker /workspace \
  && chown -R coder:coder /kaniko /workspace
ENV SSL_CERT_DIR=/kaniko/ssl/certs

# Switch to default user
USER coder
ENV USER=coder
ENV HOME=/home/coder
WORKDIR ${PROJECTS_ROOT}

# Install pixi for venv management (User level)
# https://pixi.prefix.dev/latest/installation/
RUN curl -fsSL https://pixi.sh/install.sh | sh

# Build Args for Metadata
ARG BUILD_DATE
LABEL build_version="Build-date:- ${BUILD_DATE}"
LABEL maintainer="rayleizhu"

# use /home/coder/.config/code-server/config.yaml to config the launch paramters
# cat ~/.config/code-server/config.yaml 
#   bind-addr: "[::]:8443"
#   auth: password
#   password: [your password] 
#   cert: true
# dumb-init: https://github.com/Yelp/dumb-init, let it be the PID 1 process to manage signal handling
# and orphan processes in container
# it seems that we no longer need dumb-init now: https://stackoverflow.com/a/77579291
EXPOSE 8443 22
ENTRYPOINT ["/usr/bin/dumb-init", "--"] 
CMD ["/usr/bin/entrypoint.sh", "--disable-telemetry", "."]
