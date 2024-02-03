ARG CUDA_VERSION=11.3.0
ARG OS_RELEASE=ubuntu20.04
#FROM nvidia/cuda:11.1-base-ubuntu20.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-${OS_RELEASE}


# ARG SET_APT_SOURCE=skip -> use official apt source
ARG SET_APT_SOURCE=tuna
ARG ENABLE_ALIYUN_DISK=1
# ARG CODE_SERVER_VERSION=None -> disable installation of codeserver
ARG CODE_SERVER_VERSION=4.7.0
ARG BUILD_DATE

LABEL build_version="Build-date:- ${BUILD_DATE}"
LABEL maintainer="rayleizhu"


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
# TODO: find ARCH automatically
ENV ARCH=amd64
RUN curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-${ARCH}.tar.gz" | tar -C /usr/local/bin -xzf - && \
  chown root:root /usr/local/bin/fixuid && \
  chmod 4755 /usr/local/bin/fixuid && \
  mkdir -p /etc/fixuid && \
  printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

# Install code-server
COPY common/install_code_server.sh install_code_server.sh 
RUN bash ./install_code_server.sh ${CODE_SERVER_VERSION} ${ARCH} && rm install_code_server.sh

# copy entrypoint script
COPY common/entrypoint.sh /usr/bin/entrypoint.sh

# install aliyunpan
COPY common/install_aliyun_disk.sh install_aliyun_disk.sh
RUN bash ./install_aliyun_disk.sh ${ENABLE_ALIYUN_DISK} && rm install_aliyun_disk.sh

# Switch to default user
USER coder
ENV USER=coder
ENV HOME=/home/coder
WORKDIR ${PROJECTS_ROOT}

# use /home/coder/.config/code-server/config.yaml to config the launch paramters
# cat ~/.config/code-server/config.yaml 
#   bind-addr: "[::]:8443"
#   auth: password
#   password: [your password] 
#   cert: true
EXPOSE 8443
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--disable-telemetry", "."]
