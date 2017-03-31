# !/bin/bash
# https://coreos.com/os/docs/latest/sdk-modifying-coreos.html
# The cork utility, included in the CoreOS mantle project, can be used to create and work with an SDK chroot.
# In order to use this utility, you must additionally have the golang toolchain installed and configured correctly.
# First, install the cork utility:

git clone https://github.com/coreos/mantle
cd mantle
./build cork
mkdir ~/bin
mv ./bin/cork ~/bin
export PATH=$PATH:$HOME/bin

# You may want to add the PATH export to your shell profile (e.g. .bashrc).
# Next, the cork utility can be used to create an SDK chroot:

mkdir coreos-sdk
cd coreos-sdk
cork create
cork enter


