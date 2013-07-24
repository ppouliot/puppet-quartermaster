#!/bin/bash
if [ $HOSTNAME = "ubuntu|debian" ]; then
  #set hostname to mac address of eth0
  NEWHOSTNAME=`/sbin/ifconfig | grep "eth" | tr -s " " | cut -d " " -f5 | /usr/bin/perl -pi -e "s/://g;"`
  echo $NEWHOSTNAME > /etc/hostname
else
  echo "Your Hostname has been previously defined"
fi

