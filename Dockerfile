# Quartermaster
# VERSION 1.0

FROM ubuntu
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" >> /etc/apt/sources.list
RUN apt-get install -y wget
RUN wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb -O /tmp/puppetlabs-release-precise.deb
RUN dpkg -i /tmp/puppetlabs-release-precise.deb
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y openssh-server git puppet ruby1.9.1 ruby1.9.1-dev rubygems
RUN gem install librarian-puppet-maestrodev
RUN echo "removing hiera,hiera.yaml,manifests,Puppetfile and files in /etc/puppet"
RUN rm -rf --verbose /etc/puppet/hiera
RUN rm -rf --verbose /etc/puppet/hiera.yaml
RUN rm -rf --verbose /etc/puppet/manifests
RUN rm -rf --verbose /usr/local/src/Puppetfile-cambridge
RUN rm -rf --verbose /etc/puppet/Puppetfile
RUN rm -rf --verbose /etc/puppet/Puppetfile.lock
RUN rm -rf --verbose /etc/puppet/.tmp
RUN rm -rf --verbose /etc/puppet/.librarian
RUN rm -rf --verbose /etc/puppet/files
RUN echo "retrieving /etc/puppet/hiera from git"
RUN git clone git@github.com:openstack-hyper-v/hiera.git /etc/puppet/hiera
RUN git clone git@github.com:openstack-hyper-v/Puppetfile-cambridge /usr/local/src/Puppetfile-cambridge
RUN git clone git@github.com:openstack-hyper-v/puppet-manifests /etc/puppet/manifests
RUN git clone git@github.com:openstack-hyper-v/puppet-extra_files /etc/puppet/files
RUN echo "creating symlink for from ./hiera.yaml to /etc/puppet/hiera.yaml"
RUN ln -s /etc/puppet/hiera/hiera.yaml /etc/puppet/hiera.yaml
RUN echo "rebuilding ipam data for accurate hieradata"
RUN echo "Building the ipam.yaml"
RUN cat /etc/puppet/hiera/ipam/header.txt > /etc/puppet/hiera/ipam.yaml
RUN echo "validating /etc/puppet/ipam/dhcp.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y /etc/puppet/ipam/dhcp.yaml
RUN echo "Creating ipam.yaml from /etc/puppet/ipam/dhcp.yaml"
RUN cat /etc/puppet/ipam/dhcp.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating /etc/puppet/ipam/virtualmachines.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y /etc/puppet/ipam/virtualmachines.yaml
RUN echo "Creating ipam.yaml from /etc/puppet/ipam/virtualmachines.yaml"
RUN cat /etc/puppet/ipam/virtualmachines.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating bladechassis.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y bladechassis.yaml
RUN echo "Creating ipam.yaml from  bladechassis.yaml"
RUN cat /etc/puppet/hiera/ipam/bladechassis.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating /etc/puppet/hiera/ipam/rack1.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y /etc/puppet/hiera/ipam/rack1.yaml
RUN echo "Creating ipam.yaml from /etc/puppet/hiera/ipam/rack2.yaml"
RUN cat /etc/puppet/hiera/ipam/rack1.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating /etc/puppet/hiera/ipam/rack2.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y /etc/puppet/hiera/ipam/rack2.yaml
RUN echo "Creating ipam.yaml from /etc/puppet/hiera/ipam/rack2.yaml"
RUN cat /etc/puppet/hiera/ipam/rack2.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating /etc/puppet/hiera/ipam/rack3.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera.yaml test -y /etc/puppet/hiera/ipam/rack3.yaml
RUN echo "Creating ipam.yaml from /etc/puppet/hiera/ipam/rack3.yaml"
RUN cat /etc/puppet/hiera/ipam/rack3.yaml >> /etc/puppet/hiera/ipam.yaml
RUN echo "validating final ipam.yaml"
RUN /usr/bin/hiera --debug -a --config /etc/puppet/hiera/ipam/hiera.yaml test -y /etc/puppet/hiera/ipam.yaml
RUN echo "Building the Puppetfile"
RUN cat /usr/local/src/Puppetfile-cambridge/src/header.txt > /usr/local/src/Puppetfile-cambridge/Puppetfile
RUN echo "Creating Puppetfile Settings"
RUN cat /usr/local/src/Puppetfile-cambridge/src/settings.puppetfile >> /usr/local/src/Puppetfile-cambridge/Puppetfile
RUN echo "Adding PuppetLabs modules to Puppetfile"
RUN cat /usr/local/src/Puppetfile-cambridge/src/puppetlabs.modules >> /usr/local/src/Puppetfile-cambridge/Puppetfile
RUN echo "Adding openstack-hyper-v modules to Puppetfile"
RUN cat /usr/local/src/Puppetfile-cambridge/src/openstack-hyper-v.modules >> /usr/local/src/Puppetfile-cambridge/Puppetfile
RUN echo "Adding all other modules to Puppetfile"
RUN cat /usr/local/src/Puppetfile-cambridge/src/misc.modules >> /usr/local/src/Puppetfile-cambridge/Puppetfile
RUN echo "Installing New Puppet file in /etc/puppet/Puppetfile"
RUN ln -f -s /usr/local/src/Puppetfile-cambridge/Puppetfile /etc/puppet/Puppetfile
RUN cd /etc/puppet && /usr/local/bin/librarian-puppet install --verbose
RUN puppet apply --debug --trace --verbose  --modulepath=/etc/puppet/modules /etc/puppet/manifests/site.pp
