# Class: quartermaster::server::squid
#
# This Class installs squid3 and modifies the configuration
# to cache package file formats and remote configuration 
# files
#
#

class quartermaster::server::squid () inherits quartermaster::params {

  class {'squid3':
    template => ('quartermaster)
  class {'squid3':
    acl => [
      "internal_network src ${network}/${netmask}",
      'windowsupdate dstdomain windowsupdate.microsoft.com',
      'windowsupdate dstdomain .update.microsoft.com',
      'windowsupdate dstdomain download.windowsupdate.com',
      'windowsupdate dstdomain redir.metaservices.microsoft.com',
      'windowsupdate dstdomain images.metaservices.microsoft.com',
      'windowsupdate dstdomain c.microsoft.com',
      'windowsupdate dstdomain www.download.windowsupdate.com',
      'windowsupdate dstdomain wustat.windows.com',
      'windowsupdate dstdomain crl.microsoft.com',
      'windowsupdate dstdomain sls.microsoft.com',
      'windowsupdate dstdomain productactivation.one.microsoft.com',
      'windowsupdate dstdomain ntservicepack.microsoft.com',
      'wuCONNECT dstdomain www.update.microsoft.com',
      'wuCONNECT dstdomain sls.microsoft.com',
      'aptget browser -i apt-get apt-http apt-cacher apt-proxy yum',
      'deburl urlpath_regex /(Packages|Sources|Release|Translations-.*)\(.(gpg|gz|bz2))?$ /pool/.*/.deb$ /(Sources|Packages).diff/ /dists/[^/]*/[^/]*/(binary-.*|source)/.',
      'cache_peer_access localhost allow aptget',
    ],
    http_access => [
      'allow internal_network',
      'allow CONNECT wuCONNECT internal_network',
      'allow CONNECT wuCONNECT localhost',
      'allow windowsupdate internal_network',
      'allow windowsupdate localhost',
    ],
  }

}
