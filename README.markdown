Quartermaster a Puppet Module for PXE Boot Installation Services
=================================================================

This system uses standard packages to create a pxeboot infrastructure.

Services include samba, nfs, apache, tftpd-hpa, squid-deb-proxy, puppetmaster-passenger.

It will allow for completely automated installs of most freely available linux distributions

The module also autogenrate all the menus and sub menus for the differnet pxe boot options.


This is still a work in progress.


Bootstrapping
-------------

Download files/librarian-puppet-bootstrap.sh directly and execute on an ubuntu system.

Basic usage
-----------

To install the pxe server

    class {'quartermaster': }

Adding a Linux distribution
---------------------------
When defining linux distributions to add to the pxe system use the following format as the name of
a defined quartermaster::pxe on your quartermaster node.

The naming convention used is as follows ${distro}-${version}-${architecture}
Specific exampes are provided below.

Naming conventions are based on each distributions release naming.


Add an Ubuntu/Debian distro
---------------------------
For Ubuntu you must specifically define the version as show below, while with Debian you must specify 
"stable" or "unstable" in the version field.


    node foo { 
      class {'quartermaster':}
      ...
      quartermaster::pxe{"ubuntu-12.04-amd64":}
      quartermaster::pxe{"ubuntu-12.10-amd64":}
      quartermaster::pxe{"debian-stable-amd64":}
    }


Add an EPL/Fedora distro
------------------------

    node foo {
      class {'quartermaster': }
      ...
      quartermaster::pxe{'fedora-16-i386':}
      quartermaster::pxe{'centos-6.3-x86_64':}
      quartermaster::pxe{'scientificlinux-6.3-x86_64':}
    }

Add OpenSuse
------------
    node foo {
      class{'quartermaster': }
      ...
      quartermaster::pxe{"opensuse-12.2-x86_64":}
    }


Adding Windows Media
--------------------

Additionally Partial PXE infrastructure can be created from this module by placing 
Windows media with the file naming on modified on the ISO samba share.

This file will be automounted and access provided via friendly naming convention
It will also autogenerate all the appropriate unattend.xml files for that ISO.

Please note, this does not generate a suitable winpe image.  You must use 
the petools module to provide that, as it must run on a windows host.

    node foo {
      class {'quartermaster': }
      ...
      quartermaster::windowsmedia{"en_windows_server_2012_x64_dvd_915478.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" }
      quartermaster::windowsmedia{"en_microsoft_hyper-v_server_2012_x64_dvd_915600.iso": activationkey => "" }
      quartermaster::windowsmedia{"en_windows_8_enterprise_x64_dvd_917522.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
      quartermaster::windowsmedia{"en_windows_8_enterprise_x86_dvd_917587.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
    }

Contributors
------------

 * Peter Pouliot <peter@pouliot.net>

Copyright and License
---------------------

Copyright (C) 2013 Peter J. Pouliot

Peter Pouliot can be contacted at: peter@pouliot.net

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
