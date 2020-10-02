#!/bin/bash

set -exv

# init helpers
helpers_dir=${MONOPACKER_HELPERS_DIR:-"/etc/monopacker/scripts"}
for h in ${helpers_dir}/*.sh; do
    . $h;
done

KERNEL_VERSION=$(uname -r)
echo "KERNEL_VERSION=$KERNEL_VERSION"
echo "REBUILD_KERNEL=$REBUILD_KERNEL"
echo "SETUP_SND_ALOOP=$SETUP_SND_ALOOP"
echo "BUILD_V4L2LOOPBACK=$BUILD_V4L2LOOPBACK"

# prevents interactive installation
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

if $REBUILD_KERNEL; then
    exit 1 # TODO
fi

# install crash debug tools
retry apt install -y linux-crashdump kmod

# kernel debug
grep 'USE_KDUMP' /etc/default/kdump-tools
echo 'USE_KDUMP=1' >> /etc/default/kdump-tools

# Ensure that we load AWS / Nitro modules
if [ "$CLOUD" = "aws" ]; then
    echo "ena" | tee --append /etc/modules
    echo "nvme" | tee --append /etc/modules
fi

# At this point we need a reboot to handle the kernel update
# this is handled in the grub script
