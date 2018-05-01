# -*- mode: ruby -*-
# vi: set ft=ruby :
required_plugins = %w(vagrant-disksize vagrant-scp vagrant-puppet-install vagrant-vbguest)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.disksize.size = '50GB'
  config.vm.synced_folder ".", "/etc/puppetlabs/code/modules/quartermaster", :mount_options => ['dmode=775','fmode=777']
  config.vm.synced_folder "./files/hiera", "/etc/puppetlabs/code/environments/production/data", :mount_options => ['dmode=775','fmode=777']
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048"]
    v.linked_clone = true
  config.puppet_install.puppet_version = :latest
  config.vm.provision "shell", inline: "/opt/puppetlabs/puppet/bin/gem install r10k hiera-eyaml"
  config.vm.provision "shell", inline: "apt-get update -y && apt-get -y install rsync curl wget git"
  config.vm.provision "shell", inline: "curl -o /etc/puppetlabs/code/environments/production/Puppetfile https://raw.githubusercontent.com/ppouliot/puppet-quartermaster/master/Puppetfile"
  config.vm.provision "shell", inline: "curl -o /etc/puppetlabs/code/environments/production/hiera.yaml https://raw.githubusercontent.com/ppouliot/puppet-quartermaster/master/files/hiera/hiera.yaml"
  config.vm.provision "shell", inline: "curl -o /etc/puppetlabs/puppet/hiera.yaml https://raw.githubusercontent.com/ppouliot/puppet-quartermaster/master/files/hiera/hiera.yaml"
  config.vm.provision "shell", inline: "cd /etc/puppetlabs/code/environments/production && /opt/puppetlabs/puppet/bin/r10k puppetfile install --verbose DEBUG2"
  config.vm.provision "shell", inline: "/opt/puppetlabs/bin/puppet module list --tree"
  config.vm.provision "shell", inline: "/opt/puppetlabs/bin/puppet apply --debug --trace --verbose --modulepath=/etc/puppetlabs/code/modules:/etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/modules /etc/puppetlabs/code/modules/quartermaster/examples/all.pp"
# Advanced Puppet Example
#config.vm.provision :shell, :privileged => false do |shell|
#  shell.inline = "puppet apply --debug --modulepath '/vagrant/#{ENV.fetch('MODULES_PATH', 'modules')}' --detailed-exitcodes '/vagrant/#{ENV.fetch('MANIFESTS_PATH', 'manifests')}/#{ENV.fetch('MANIFEST_FILE', 'site.pp')}'"
#end

  end
  config.vm.define "quartermaster" do |v|
#   v.vm.box = "ubuntu/xenial64"
    v.vm.hostname = "quartermaster.contoso.ltd"
    v.vm.network "private_network", ip: "192.168.0.22"
  end

end
