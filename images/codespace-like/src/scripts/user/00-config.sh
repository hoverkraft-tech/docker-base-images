#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

echo "+ copying user config files for ${USER}"
rsync -a --size-only /build/config/user/ "${HOME}/"
