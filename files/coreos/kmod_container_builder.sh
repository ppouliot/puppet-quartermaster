#!/bin/bash
# http://coreos.com/os/docs/latest/kernel-modules.html 

# Read system configuration files to determine the URL of the development container that corresponds to the current Container Linux version
. /usr/share/coreos/release
. /usr/share/coreos/update.conf
. /etc/coreos/update.conf
url="http://${GROUP:-stable}.release.core-os.net/$COREOS_RELEASE_BOARD/$COREOS_RELEASE_VERSION/coreos_developer_container.bin.bz2"

# Download, decompress, and verify the development container image.
gpg2 --recv-keys 48F9B96A2E16137F  # Fetch the buildbot key if neccesary.
curl -L "$url" |
    tee >(bzip2 -d > coreos_developer_container.bin) |
    gpg2 --verify <(curl -Ls "$url.sig") -

# Start the development container with the host's writable modules directory mounted into place.
sudo systemd-nspawn \
    --bind=/lib/modules \
    --image=coreos_developer_container.bin


# Now, inside the container, fetch the Container Linux packages and check out the current version.
# The git checkout command might fail on the latest alpha, before its version is branched from master, so staying on the master branch is correct in that case.

emerge-gitclone
. /usr/share/coreos/release
git -C /var/lib/portage/coreos-overlay checkout build-${COREOS_RELEASE_VERSION%%.*}

# Still inside the container, download and prepare the Linux kernel source for building external modules.
emerge -gKv coreos-sources
gzip -cd /proc/config.gz > /usr/src/linux/.config
make -C /usr/src/linux modules_prepare

sudo depmod
