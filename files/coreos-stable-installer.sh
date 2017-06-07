#!/bin/bash

NEWHOSTNAME=/usr/bin/ip a | /usr/bin/grep "ether" | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f3 | /usr/bin/sed -e "s/://g;"
sudo hostname $NEWHOSTNAME


# Download cloud-config
curl -O http://quartermaster/coreos//coreos-stable-amd64.cloud-config.yml
# Run install 
virtual_disk="/dev/vda"    # /   (root directory)
phyiscal_disk="/dev/sda"    # /   (root directory)

disk_types=("/dev/vda" "/dev/sda" )
for element in ${disk_types[*]};
do
#if [ -b "$virtual_disk" ]
#then
  echo "$element is a block device."
  for partition in $(sudo parted -s $element print|awk '/^ / {print $1}')
  do
    sudo parted -s $element rm ${partition}
  done
  # Zero MBR
  sudo dd if=/dev/zero of=$virtual_disk bs=512 count=1
  sudo coreos-install -d $virtual_disk -C stable -c coreos-stable-amd64.cloud-config.yml
#fi
done

#if [ -b "$physical_disk" ]
#then
#  echo "$physical_disk is a block device."
#  for v_partition in $(sudo parted -s $physical_disk print|awk '/^ / {print $1}')
#  do
#    sudo parted -s $physical_disk rm ${v_partition}
#  done
  # Zero MBR
#  sudo dd if=/dev/zero of=$physical_disk bs=512 count=1
#  sudo coreos-install -d $physical_disk -C stable -c coreos-stable-amd64.cloud-config.yml
#fi


# Reboot 
sudo reboot
