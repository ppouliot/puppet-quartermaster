#!/usr/bin/expect

set timeout 15
exp_internal 1
log_user 1


#for {set i 1} {$i <= 40} {incr i 1} {
#  spawn ssh -o StrictHostKeyChecking=no [lindex $argv 0].$i -l root
spawn ssh -o StrictHostKeyChecking=no [lindex $argv 0] -l root
expect {
  "yes/no" { 
    send "yes\r"
    exp_continue
   }

   "*?assword" {
     send "centos\r"
     exp_continue
   }
   "*?assword" {
     send "centos\r"
     exp_continue
   }

   "*# " {
#     send "touch RUN_PUPPET_BEGIN && exit\r"
     send "screen -S BruteForcePuppetRun -d -m puppet agent --debug --trace --verbose --test --waitforcert=60 --server=quartermaster.openstack.tld && exit\r"
     exp_continue
   }
}
