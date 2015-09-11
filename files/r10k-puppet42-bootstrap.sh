#!/bin/bash
echo -n "creating framework to support automated puppet/r10k workflows"

echo -n "- installing git"
apt-get update -y && apt-get install -y git
echo -n "- changing to /etc"
cd /etc/
rm -rf /etc/puppet
echo -n "- Retrieving Base /etc/puppet"
git clone https://github.com/ppouliot/puppet-etc_puppet puppet

echo -n "- Installing PuppetLabs Repositories"
cd /tmp

# this is a debian/ubuntu specific command
release=`lsb_release -c | awk '{print $2}'`

echo '### INSTALLING PUPPETLABS APT REPO ###'
wget http://apt.puppetlabs.com/puppetlabs-release-PC1-$release.deb; dpkg -i puppetlabs-release-PC1-$release.deb
if [ $? $test -eq 1 ]; then
   echo "Could not find puppetlabs release for $release.  Trying alternative."
   wget http://apt.puppetlabs.com/puppetlabs-release-PC1-precise.deb; dpkg -i puppetlabs-release-PC1-precise.deb
fi

echo '### UPDATING AND INSTALLING NECESSARY PACKAGES ###'
apt-get update -y && apt-get install -y openssh-server puppet_agent ruby ruby-dev python-software-properties


echo "### INSTALLING  R10K ###"
gem install r10k

echo "### RUNNING R10K ###"
cd /etc/puppet && r10k --verbose DEBUG puppetfile install
cd /etc/puppet && r10k --verbose DEBUG deploy environment -pv

