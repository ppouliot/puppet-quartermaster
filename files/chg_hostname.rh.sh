#!/bin/bash
HOSTNAME=`/bin/hostname -s`
if [ "$HOSTNAME" = "localhost" -o "$HOSTNAME" = "centos" -o "$HOSTNAME" = "fedora" -o "$HOSTNAME" = "scientificlinux" -o "$HOSTNAME" = "oraclelinux" ];
then
#set hostname to mac address of eth0
NEWHOSTNAME=`/sbin/ifconfig | grep "eth" | tr -s " " | cut -d " " -f5 | /usr/bin/perl -pi -e "s/://g;"`
# Setting Hostname
cat << EOF > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=$NEWHOSTNAME
EOF
  echo "Your Hostname is:" $HOSTNAME "your newhostname is" $NEWHOSTNAME
else
  echo "Your Hostname is:" $HOSTNAME "your newhostname is" $NEWHOSTNAME
fi
