#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

echo "+ copying user config files for ${USER}"
rsync -a --size-only /build/config/user/ "${HOME}/"

# Create runtime links here so the source archive is usable outside the image.
ln -sfnT "${HOME}/work/.ssh" "${HOME}/.ssh"
ln -sfnT "${HOME}/work/.gnupg" "${HOME}/.gnupg"
