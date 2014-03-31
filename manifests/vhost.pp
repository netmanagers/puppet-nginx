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
  $port           = '80',
  $template       = 'nginx/vhost/vhost.conf.erb',
  $priority       = '50',
  $serveraliases  = '',
  $create_docroot = true,
  $enable         = true,
  $owner          = '',
  $groupowner     = ''
) {

  include nginx
  include nginx::params

  $real_owner = $owner ? {
    ''      => $nginx::config_file_owner,
    default => $owner,
  }

  $real_groupowner = $groupowner ? {
    ''      => $nginx::config_file_group,
    default => $groupowner,
  }

  $bool_create_docroot = any2bool($create_docroot)

  file { "${nginx::vdir}/${priority}-${name}.conf":
    content => template($template),
    mode    => $nginx::config_file_mode,
    owner   => $nginx::config_file_owner,
    group   => $nginx::config_file_group,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Some OS specific settings:
  # On Debian/Ubuntu manages sites-enabled
  case $::operatingsystem {
    ubuntu,debian,mint: {
      $manage_file = $enable ? {
        true  => "${nginx::vdir}/${priority}-${name}.conf",
        false => absent,
      }

      file { "NginxVHostEnabled_${name}":
        ensure  => $manage_file,
        path    => "${nginx::vdir_enable}/${priority}-${name}.conf",
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
    redhat,centos,scientific,fedora: {
      # include nginx::redhat
    }
    default: { }
  }

  if $bool_create_docroot == true {
    file { $docroot:
      ensure => directory,
      owner  => $real_owner,
      group  => $real_groupowner,
      mode   => '0775',
    }
  }

}
