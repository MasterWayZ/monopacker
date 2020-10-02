#!/bin/bash

set -exv

# init helpers
helpers_dir=${MONOPACKER_HELPERS_DIR:-"/etc/monopacker/scripts"}
for h in ${helpers_dir}/*.sh; do
    . $h;
done

echo "new kernel: $(uname -r)"

# verify kernel crash dump is ready to go
kdump-config show

# uninstall things we used to build the kernel
apt-get remove -y dkms
