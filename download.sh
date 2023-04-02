#!/usr/bin/env bash

echo "Downloading Kernel Sources.."
git clone --depth 1 $KERNEL_SOURCE -b $KERNEL_BRANCH $CIRRUS_WORKING_DIR/$DEVICE_CODENAME
