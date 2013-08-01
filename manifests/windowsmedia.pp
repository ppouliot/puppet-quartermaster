# Class: quartermaster::windowsmedia
#
# This Class defines Windows Media to the pxe infrastructrure
# based on the name of the ISO provided
# ISOs can be take offical unmodified ISOs and it will parse the name
# determining infromation to generate unattend.xml for the media
#
# Parameters: none
#
# Actions:
#
# Sample Usage:
#    quartermaster::windowsmedia{"en_windows_8_enterprise_x86_dvd_917587.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
#

define quartermaster::windowsmedia( $activationkey ) {
  $isofile  = $name
#    $iso_path = "${quartermaster::wwwroot}/WinPE/ISO/${name}"
  $iso_path = "${quartermaster::winpe::windows_isos}/${name}"

  if $name =~ /([a-z]+)_([a-zA-Z_\-]+)_([0-9]+)_([x0-9]+)_dvd_([0-9]+).iso/ {
    $w_lang          = $1
    $w_dist          = $2
    $w_release       = $3
    $w_media_arch    = $4
    $w_build         = $5
  }

#if $name =~ /([a-z]+)_([a-zA-Z]+)_([0-9]+)_([a-zA-Z]+)_([x0-9]+)_dvd_([0-9]+).iso/ {
  if $name =~ /([a-z]+)_([a-zA-Z]+)_([0-9]_[a-zA-Z]+)_([x0-9]+)_dvd_([0-9]+).iso/ {
    $w_lang          = $1
    $w_dist          = $2
    $w_release       = $3
    $w_media_arch    = $4
    $w_build         = $5
  }

  $w_arch = $w_media_arch ?{
    /(x64)/ => 'amd64',
    /(x86)/ => 'i386',
  }

  $w_menu_option = $w_dist ?{
    /(windows_server)/           =>'S',
    /(microsoft_hyper-v_server)/ =>'V',
    /(windows)/                  =>'W',
  }

  $w_distro = $w_dist ?{
    /(microsoft_hyper-v_server)/ => 'hyper-v_server',
    default                      => $w_dist,
  }

  $w_flavor = $w_dist ?{
    /(windows_server)/           =>'server',
    /(microsoft_hyper-v_server)/ =>'hyper-v',
    /(windows)/                  =>'client',
  }

  notify {"${name}: WINDOWS LANGUAGE: ${w_lang}": }
  notify {"${name}: WINDOWS DISTRIBUTION ${w_distro}": }
  notify {"${name}: WINDOWS RELEASE: ${w_release}": }
  notify {"${name}: WINDOWS MEDIA ARCH: ${w_media_arch}": }
  notify {"${name}: WINDOWS BUILD NUMBER: ${w_build}": }
  notify {"${name}: WINDOWS ARCH: ${w_arch}": }

  file {"w_iso_file_${name}":
    path => "${iso_path}/${name}",
  }

  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft" ],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft" ],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft" ],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft" ],
    }
  } 
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/mnt"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/mnt":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe"],
    }
  } 
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe"],
    }
  } 
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}":
      ensure  => link,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      target  => "${quartermaster::wwwroot}/microsoft/mount/${name}",
      require =>  File[ "${quartermaster::wwwroot}/microsoft" ],
    }
  }

  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/winpe.wim"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/winipe.wim":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/sources/boot.wim" ,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}"],
    }
  } 
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/etfsboot.com"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/etfsboot.com":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/boot/etfsboot.com",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require =>  File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}"],
    }
  } 
  exec {"wimlib-imagex-mount-${name}":
      command => "/usr/bin/wimlib-imagex mount ${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/winpe.wim 1 ${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt",  
      require => [ File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/winpe.wim"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt],
  } 

#  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/oscdimg.exe"]) {
#    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/oscdimg.exe":
#      ensure  => directory,
#      recurse => true,
#      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt/Windows/Boot/PXE/oscdimg.exe",
#      owner   => 'www-data',
#      group   => 'www-data',
#      mode    => '0644',
#      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/mnt"],
#    }
#  } 
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.com"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.com":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt/Windows/Boot/PXE/pxeboot.com",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
#      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/oscdimg.exe"],
      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/mnt"],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.0"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.0":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt/Windows/Boot/PXE/pxeboot.0",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.com"],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/bootmgr.exe"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/bootmgr.exe":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt/Windows/Boot/PXE/bootmgr.exe",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/pxeboot.0"],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/boot.sdi"]) {
    file { "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/boot.sdi":
      ensure  => directory,
      recurse => true,
      source  => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt/Windows/Boot/PXE/boot.sdi",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => [ Exec["wimlib-imagex-mount-${name}"], File[ "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/pxe/Boot/bootmgr.exe"],
    }
  }
  exec {"wimlib-imagex-unmount-${name}":
      command => "/usr/bin/wimlib-imagex unmount ${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/winpe.wim 1 ${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/${w_arch}/pxe/mnt",  
      require => Exec["wimlib-imagex-mount-${name}"] 
  } 


  file { "${name}-setup.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/${name}.cmd",
    content => template("quartermaster/winpe/menu/${w_flavor}.erb"),
  }

  file { "${name}-core-unattend.xml":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    path    => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend/core-${w_arch}.xml",
    content => template('quartermaster/autoinst/unattend/core.erb'),
  }

  if $w_distro == 'windows_server'{
    file { "${name}-server-unattend.xml":
      ensure  => file,
      owner   => 'nobody',
      group   => 'nogroup',
      mode    => $quartermaster::exe_mode,
      path    => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend/server-${w_arch}.xml",
      content => template('quartermaster/autoinst/unattend/server.erb'),
    }
  }
  if $w_distro == 'windows_server'{
    file { "${name}-hyperv-unattend.xml":
      ensure  => file,
      owner   => 'nobody',
      group   => 'nogroup',
      mode    => $quartermaster::exe_mode,
      path    => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend/hyperv-${w_arch}.xml",
      content => template('quartermaster/autoinst/unattend/server.erb'),
    }
  }
  if $w_distro == 'hyper-v_server'{
    file { "${name}-domain-hyper-v-unattend.xml":
      ensure  => file,
      owner   => 'nobody',
      group   => 'nogroup',
      mode    => $quartermaster::exe_mode,
      path    => "${quartermaster::wwwroot}/microsoft/${w_distro}/${w_release}/unattend/domain-${w_arch}.xml",
      content => template('quartermaster/autoinst/unattend/domain.erb'),
    }
  }
# This needs to be removed and moved to concat.
  exec {"create_initcmd-${name}":
    command => "${quartermaster::wwwroot}/bin/concatenate_files.sh ${quartermaster::wwwroot}/microsoft/winpe/system/menu ${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    cwd     => "${quartermaster::wwwroot}/microsoft/winpe/system",
    creates => "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    notify  => Service[ 'tftpd-hpa' ],
    require => File["${quartermaster::wwwroot}/bin/concatenate_files.sh"],
  }

  file { "A_init.cmd-${name}":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/A${name}",
    content => template('quartermaster/winpe/menu/A_init.erb'),
  }
  file { "B_init.cmd-${name}":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/B${name}",
    content => template('quartermaster/winpe/menu/B_init.erb'),
  }
  file { "C_init.cmd-${name}":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/C${name}",
    content => template('quartermaster/winpe/menu/C_init.erb'),
  }
}
