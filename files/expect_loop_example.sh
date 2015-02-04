#!/usr/bin/expect -f
set timeout 10
exp_internal 1
log_user 1

set ssh_user [lindex $argv 0]
set ssh_passwd [lindex $argv 1]
#set host [lindex $argv 2]
set subnet [lindex $argv 2]
set command "apt-get install -y screen"

# "screen -S BruteForcePuppetRun -d -m puppet agent --debug --trace --verbose --test --waitforcert=60 --server=<%= @fqdn %>"



for {set i 1} {$i <= 40} {incr i 1} {
  set logfile "$subnet.$i-[clock format [clock seconds] -format %Y%m%d]"
  log_file $logfile
  spawn ssh -o StrictHostKeyChecking=no $subnet.$i -l $ssh_user $command
# apt-get install -y screen &
# screen -S BruteForcePuppetRun -d -m top
#puppet agent --debug --trace --verbose --test --waitforcert=60 --server=quartermaster.openstack.tld
  expect "yes/no" { 
    send "yes\r"
    expect "*?assword" { send "$ssh_passwd\r" }
    } "*?assword" { send "$ssh_passwd\r" }
  log_file
  }
