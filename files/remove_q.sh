#!/bin/bash
echo "removing windows directories while preserving ISOs and Mount"
rm -rf \
/srv/quartermaster/microsoft/hyper-v \
/srv/quartermaster/microsoft/server \
/srv/quartermaster/microsoft/windows \
/srv/quartermaster/microsoft/winpe ;


rm -rf \
/srv/quartermaster/bin \
/srv/quartermaster/centos \
/srv/quartermaster/debian \
/srv/quartermaster/fedora \
/srv/quartermaster/kickstart 
/srv/quartermaster/opensuse \
/srv/quartermaster/preseed \
/srv/quartermaster/scientificlinux \
/srv/quartermaster/ubuntu ;

