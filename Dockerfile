FROM msopenstack/sentinel-ubuntu_trusty:latest
 
RUN apt-get update -y
RUN apt-get install software-properties-common -y
RUN puppet module install puppetlabs-stdlib
RUN puppet module install puppetlabs-concat
RUN puppet module install puppetlabs-inifile
RUN puppet module install puppetlabs-apt
RUN puppet module install puppetlabs-tftp
RUN puppet module install puppetlabs-apache
RUN puppet module install puppetlabs-puppetdb
RUN puppet module install puppet-staging
RUN puppet module install stephenrjohnson-puppet
RUN puppet module install thias-squid3
RUN puppet module install thias-samba
RUN puppet module install pdxcat-autofs
RUN cd /etc/puppet/modules && git clone https://github.com/ppouliot/puppet-quartermaster quartermaster
RUN cp -R /etc/puppet/modules/quartermaster/files/hiera/hiera.yaml /etc/puppet/hiera.yaml
RUN rm -rf /etc/hiera.yaml
RUN ln -s /etc/puppet/hiera.yaml /etc/hiera.yaml
RUN mkdir /etc/puppet/hiera
RUN cp -R /etc/puppet/modules/quartermaster/files/hiera/quartermaster.yaml /etc/puppet/hiera/quartermaster.yaml
RUN puppet apply --debug --trace --verbose /etc/puppet/modules/quartermaster/examples/init.pp
