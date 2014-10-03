# this is a debian/ubuntu specific command
release=`lsb_release -c | awk '{print $2}'`

echo '### INSTALLING PUPPETLABS APT REPO ###'
wget http://apt.puppetlabs.com/puppetlabs-release-$release.deb; dpkg -i puppetlabs-release-$release.deb
if [ $? $test -eq 1 ]; then
   echo "Could not find puppetlabs release for $release.  Trying alternative."
   wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb; dpkg -i puppetlabs-release-precise.deb
fi

echo '### UPDATING AND INSTALLING NECESSARY PACKAGES ###'
apt-get update -y && apt-get install -y openssh-server git puppet ruby ruby-dev

echo "### INSTALLING Q's PUPPETFILE INTO /etc/puppet ###"
wget https://raw.github.com/openstack-hyper-v/puppet-quartermaster/master/Puppetfile -O /etc/puppet/Puppetfile

echo "### INSTALLING  R10K ###"
gem install r10k

echo "### RUNNING R10K ###"
cd /etc/puppet && r10k --verbose DEBUG puppetfile install

#Setting Minimal hiera for QuarterMaster
cp -R /etc/puppet/modules/quartermaster/files/hiera /etc/puppet/hiera
echo "creating symlink for from ./hiera.yaml to /etc/puppet/hiera.yaml"
ln -s /etc/puppet/hiera/hiera.yaml /etc/puppet/hiera.yaml

echo "### BOOTSTRAPPING QUARTERMASTER ###"
puppet apply --verbose --trace --debug --modulepath=/etc/puppet/modules /etc/puppet/modules/quartermaster/tests/init.pp
