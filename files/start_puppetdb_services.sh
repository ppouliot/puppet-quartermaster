# This Script is Managed by in the 
#Puppet Node Definition for puppet1.openstack.tld
#!/bin/bash
puppet resource service puppet ensure=running
puppet resource service puppetdb ensure=running
puppet resource service postgresql ensure=running
puppet resource service mcollective ensure=running
