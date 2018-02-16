# This Script is Managed by in the 
#Puppet Node Definition for puppet1.openstack.tld
#!/bin/bash
puppet resource service puppet ensure=stopped
puppet resource service puppetdb ensure=stopped
puppet resource service postgresql ensure=stopped
puppet resource service mcollective ensure=stopped
