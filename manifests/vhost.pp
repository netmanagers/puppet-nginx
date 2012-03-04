# Definition: nginx::vhost
#
# This class installs nginx Virtual Hosts
#
# Parameters:
# - The $port to configure the host on
# - The $docroot provides the Documentation Root variable
# - The $template option specifies whether to use the default template or override
# - The $priority of the site
# - The $serveraliases of the site
#
# Actions:
# - Install Nginx Virtual Hosts
#
# Requires:
# - The nginx class
#
# Sample Usage:
#  nginx::vhost { 'site.name.fqdn':
#  priority => '20',
#  port => '80',
#  docroot => '/path/to/docroot',
#  }
#
define nginx::vhost (
  $docroot,
  $port          = '80',
  $template      = 'nginx/vhost/vhost.conf.erb',
  $priority      = '50',
  $serveraliases = '',
  $enable        = true ) {

  include nginx
  include nginx::params

  file { "${nginx::vdir}/${priority}-${name}.conf":
    content => template($template),
    mode    => $nginx::configfile_mode,
    owner   => $nginx::configfile_owner,
    group   => $nginx::configfile_group,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Some OS specific settings:
  # On Debian/Ubuntu manages sites-enabled 
  case $operatingsystem {
    ubuntu,debian,mint: {
      file { "ApacheVHostEnabled_$name":
        path   => "/etc/nginx2/sites-enabled/${priority}-${name}.conf",
        ensure => $enable ? {
          true  => "${nginx::vdir}/${priority}-${name}.conf",
          false => absent,
        },
        require => Package["nginx"],
      }
    }
    redhat,centos,scientific,fedora: {
      # include nginx::redhat
    }
    default: { }
  }

}
