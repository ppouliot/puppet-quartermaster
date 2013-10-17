# Example Kickstart Post showing auto update of firmware

%post --interpreter=/bin/bash

# Just to make sure that network is up for acessing "Dell Online Repository" over network
/sbin/service NetworkManager restart;
/sbin/service network restart;

# Setting Up/Bootstrapping "Dell Linux Online Repository"
#     We can also use a URL to local mirror of "Dell Linux Online Repository", if available
wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash;

# Check return value of above wget command to confirm everything is ok to proceed further
ret_val=$(echo $?);

if [ "$ret_val" = "0" ]; then
   #  Install required firmware tools
   yum -y install dell_ft_install;

   # Check return value of above yum command to confirm everything is ok to proceed further
   ret_val=$(echo $?);
   if [ "$ret_val" = "0" ]; then
      # Downloading applicable firmware
      #     Bootstrap firmware is a process where the latest BIOS or Firmware
      #     update RPMs for the system are downloaded from the repository, along
      #     with the utilities necessary to inventory and apply updates on the system
      yum -y install $(bootstrap_firmware);

      # Check return value of above yum command to confirm everything is ok to proceed further
      ret_val=$(echo $?);
      if [ "$ret_val" = "0" ]; then
         # Completing "Inventory" of the system to know available/installed BIOS and other firmware versions.
         #     File /var/log/pre_update_inventory.xml contains current BIOS and other firmware details before going for the updates as shown below.
         inventory_firmware > /var/log/pre_update_inventory.xml;

         # Check return value of above inventory_firmware command to confirm everything is ok to proceed further
         ret_val=$(echo $?);
         if [ "$ret_val" = "0" ]; then
            echo "*** NOTE: System Inventory Went Through Successfully ...";
         else
            echo "*** ERROR: System Inventory Failed ...";
         fi

         # Update BIOS and other firmware on the system to their
         #     latest available versions on "Dell Linux Online Repository"
         update_firmware --yes;

         # Check return value of above update_firmware command to confirm everything is ok or not
         ret_val=$(echo $?);
         if [ "$ret_val" = "0" ]; then
            echo "*** NOTE: BIOS & Firmware Updates Went Through Successfully ...";
         else
            echo "*** ERROR: BIOS and/or Firmware Updates Failed. Please check /var/log/firmware-updates.log to know more details.";
         fi

         # The above two yum commands installed many RPMs. Here we update /etc/rc.local to take care of inventory post updates inventory and cleaning RPMs.
         # Updates to /etc/rc.local and /var/log/post_update_inventory.xml is post updates inventory
         # We append all required commands to /etc/rc.local to complete post updates inventory and cleaning RPMs in a "single line", that is last line in /etc/rc.local. Later /etc/rc.local will be updated not to include this "single line".
         echo "inventory_firmware > /var/log/post_update_inventory.xml; yum -y remove dell_ie_*; yum -y remove \$(bootstrap_firmware); yum -y erase \$(rpm -qa | grep srvadmin); rpm -e \$(rpm -qa | grep dell); yum clean all; rm -rf /var/cache/yum/*; rm -f /etc/yum.repos.d/dell-omsa-repository.repo; cp -v /etc/rc.local /tmp/rc.local; grep -v \"inventory_firmware > /var/log/pre_update_inventory.xml;\" /tmp/rc.local > /etc/rc.local;" >> /etc/rc.local;
      else
         echo "*** ERROR: Applicable Firmware Download Failed ..";
      fi
   else
      echo "*** ERROR: Required Firmware Tools Installation Failed ..";
   fi
else
   echo "*** ERROR: Setting Up/Bootstrapping \"Dell Linux Online Repository\" Failed ...";
fi

echo; echo "NOTE: It is suggested to reboot the system. System will be auto-rebooted ...!!";

%end
