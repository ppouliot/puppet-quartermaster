FROM puppet/puppet-agent
MAINTAINER peter@pouliot.net
RUN mkdir -p /etc/puppetlabs/code/modules/quartermaster
COPY . /etc/puppetlabs/code/modules/quartermaster

COPY Puppetfile /etc/puppetlabs/code/environments/production/Puppetfile
COPY files/hiera /etc/puppetlabs/code/environments/production/data
COPY files/hiera/hiera.yaml /etc/puppetlabs/code/environments/production/hiera.yaml
COPY files/hiera/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
COPY Dockerfile Dockerfile
COPY VERSION VERSION

RUN \
    apt-get update -y && apt-get install git software-properties-common -y \
    && gem install r10k \
    && cd /etc/puppetlabs/code/environments/production/ \
    && r10k puppetfile install --verbose DEBUG2 \
    && ln -s data/hiera.yaml /etc/puppetlabs/hiera.yaml \
    && cp data/quartermaster.yaml data/nodes/`facter | grep fqdn | awk '{print $3}'| sed -e 's/\"//g'| awk -F. '{print $1}'`.yaml \
    && ls data/nodes && echo $HOSTNAME \
    && puppet module list \
    && puppet module list --tree 
RUN \
    puppet apply --debug --trace --verbose --modulepath=/etc/puppetlabs/code/environments/production/modules /etc/puppetlabs/code/environments/production/modules/quartermaster/examples/init.pp \
    &&  puppet apply --debug --trace --verbose --modulepath=/etc/puppetlabs/code/environments/production/modules /etc/puppetlabs/code/environments/production/modules/quartermaster/examples/light.pp
EXPOSE 80
