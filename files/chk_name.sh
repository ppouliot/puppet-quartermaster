# Install Fedor EPL Repos if we are not Fedora
echo "Checking hostname -s and installing EPL Package if Necessary"

DISTRO=`hostname -s`
echo "Your DISTRO is" $DISTRO

if [ "$DISTRO" = "centos" -o "$DISTRO" = "scientificlinux" -o "$DISTRO" = "oraclelinux" ]; then
  echo -n "Install Fedora EPL Repos"
  rpm -uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
fi


DNSNAME=`cat /var/lib/dhclient/*.lease |grep -m 1 "option host-name" |tr -s " " | cut -d " " -f4| perl -pi -e "s/\"//g;" | perl -pi -e "s/\;//g;"`
echo "Your DNSNAME is" $DNSNAME
if [ $DNSNAME ]
then
  # SET HOSTNAME TO DHCP CLIENT VALUE
  HOSTNAME=$DNSNAME
  ECHO
else
  # Basic Hostname Check
  HOSTNAME=`hostname -s`

fi

#
#yum install puppet rubygems make gcc ruby-devel git -y

#gem install librarian-puppet-maestrodev

#if [ "$HOSTNAME" = "localhost" -o "$HOSTNAME" = "centos" -o "$HOSTNAME" = "fedora" -o "$HOSTNAME" = "scientificlinux" -o "$HOSTNAME" = "oraclelinux" ]; then
if [ "$HOSTNAME" = "centos" -o "$HOSTNAME" = "fedora" -o "$HOSTNAME" = "scientificlinux" -o "$HOSTNAME" = "oraclelinux" ]; then
#if [ "$HOSTNAME" = "localhost" ]; then
#set hostname to mac address of eth0
NEWHOSTNAME=`/sbin/ifconfig | grep "eth" | tr -s " " | cut -d " " -f5 | /usr/bin/perl -pi -e "s/://g;"`
# Setting Hostname
#cat << EOF > /etc/sysconfig/network
#NETWORKING=yes
HOSTNAME=$NEWHOSTNAME
#EOF
  echo "### DNSNAME: "$DNSNAME "HOSTNAME:" $HOSTNAME "NEWHOSTNAME:" $NEWHOSTNAME "###"
else
  echo "### DNSNAME: "$DNSNAME "HOSTNAME:" $HOSTNAME "NEWHOSTNAME:" $NEWHOSTNAME "###"
fi

# legacy way of doing it
#NEWHOSTNAME=`/sbin/ifconfig | grep "eth" | tr -s " " | cut -d " " -f5 | /usr/bin/perl -pi -e "s/://g;"`
## Setting Hostname
cat << EOF > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=$HOSTNAME
EOF


if [ -f /etc/sysconfig/puppet ]
   then
   /bin/sed -i -e "s/^START=no/START=yes/" /etc/sysconfig/puppet
fi

if [ -f /etc/puppet/puppet.conf ]
   then
   cat << EOF >> /etc/puppet/puppet.conf
[agent]
server=<%= @fqdn %>
EOF

fi
chkconfig puppet on

