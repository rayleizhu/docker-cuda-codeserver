#!/bin/sh
set -eu

# We do this first to ensure sudo works below when renaming the user.
# Otherwise the current container UID may not exist in the passwd database.
eval "$(fixuid -q)"

if [ "${DOCKER_USER-}" ] && [ "$DOCKER_USER" != "$USER" ]; then
  echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null
  # Unfortunately we cannot change $HOME as we cannot move any bind mounts
  # nor can we bind mount $HOME into a new home as that requires a privileged container.
  sudo usermod --login "$DOCKER_USER" coder
  sudo groupmod -n "$DOCKER_USER" coder

  USER="$DOCKER_USER"

  sudo sed -i "/coder/d" /etc/sudoers.d/nopasswd
fi


# launch code-server if it has been installed
# https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script
if command -v /usr/bin/code-server &> /dev/null; then
  dumb-init /usr/bin/code-server "$@"
fi
