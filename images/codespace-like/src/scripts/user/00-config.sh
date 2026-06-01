#!/bin/bash

set -eu -o pipefail

export DEBIAN_FRONTEND=noninteractive

echo "+ copying user config files for ${USER}"
rsync -va --size-only /build/config/user/ "${HOME}/"
