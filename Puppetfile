# This Puppetfile generates a working Quartermaster for generating all necessary images.
#
# Git Settings
git_protocol=ENV['git_protocol'] || 'git'
base_url = "#{git_protocol}://github.com"

# 
branch_name = 'origin/grizzly'
mod 'puppetlabs/postgresql', :git => "#{base_url}/puppetlabs/puppetlabs-postgresql", :ref => 'master'
mod 'puppetlabs/puppetdb', :git => "#{base_url}/puppetlabs/puppetlabs-puppetdb", :ref => 'master'
mod 'puppetlabs/firewall', :git => "#{base_url}/puppetlabs/puppetlabs-firewall", :ref => 'master'
mod 'puppetlabs/ntp', :git => "#{base_url}/puppetlabs/puppetlabs-ntp", :ref => 'master'
mod 'puppetlabs/apache', :git => "#{base_url}/puppetlabs/puppetlabs-apache", :ref => 'master'
mod 'puppetlabs/stdlib', :git => "#{base_url}/puppetlabs/puppetlabs-stdlib", :ref => 'master'
mod 'puppetlabs/apt', :git => "#{base_url}/puppetlabs/puppetlabs-apt", :ref => 'master'

# stephenrjohnson
# this what I am testing Puppet 3.2 deploys with
# I am pointing it at me until my patch is accepted
mod 'stephenjohrnson/puppet', :git => "#{base_url}/stephenrjohnson/puppetlabs-puppet", :ref => 'master'

# upstream is ripienaar
mod 'ripienaar/concat', :git => "#{base_url}/ripienaar/puppet-concat", :ref => 'master'

# upstream is cprice-puppet/puppetlabs-inifile
mod 'cprice404/inifile', :git => "#{base_url}/cprice-puppet/puppetlabs-inifile"


mod 'ppouliot/quartermaster', :git => "#{base_url}/ppouliot/puppet-quartermaster"
