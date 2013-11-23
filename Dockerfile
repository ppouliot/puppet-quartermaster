# Quartermaster
# VERSION 1.0

FROM ubuntu
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" >> /etc/apt/sources.list
RUN apt-get install -y wget
RUN wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb -O /tmp/puppetlabs-release-precise.deb
RUN dpkg -i /tmp/puppetlabs-release-precise.deb
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y openssh-server git puppet ruby1.9.1 ruby1.9.1-dev rubygems
RUN wget https://raw.github.com/openstack-hyper-v/Puppetfile-cambridge/master/Puppetfile -O /etc/puppet/Puppetfile
RUN gem install librarian-puppet-maestrodev
RUN cd /etc/puppet && librarian-puppet install --verbose
RUN puppet apply --verbose --trace --debug --modulepath=/etc/puppet/modules /etc/puppet/modules/quartermaster/tests/init.pp
