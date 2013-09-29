# define: nginx::resource::upstream
#
# This definition creates a new upstream proxy entry for NGINX
#
# Parameters:
#   [*ensure*]      - Enables or disables the specified location (present|absent)
#   [*vhost*]       - Defines the default vHost for this upstream entry to include with
#   [*members*]     - Array of member URIs for NGINX to connect to. Must follow valid NGINX syntax.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::upstream { 'proxypass':
#    ensure  => present,
#    vhost   => 'test2.local',
#    members => [
#      'localhost:3000',
#      'localhost:3001',
#      'localhost:3002',
#    ],
#  }
define nginx::resource::upstream (
  $members,
  $ensure            = present,
  $vhost             = undef,
  $template_upstream = 'nginx/conf.d/upstream.erb',
) {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => $nginx::manage_service_autorestart,
  }

  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  ## Check for various error condtiions
  if ($vhost == undef) {
    fail('Cannot create an upstream reference without attaching to a virtual host')
  }

  case $::operatingsystem {
    ubuntu,debian,mint: {
      concat::fragment { "${vhost}+105-upstream.tmp":
        ensure  => $ensure_real,
        order   => '105',
        content => template($template_upstream),
        target  => "${nginx::config_dir}/sites-available/${vhost}.conf",
        notify  => $nginx::manage_service_autorestart,
      }
    }
    default: {
      file { "${nginx::config_dir}/conf.d/${vhost}-upstream.conf":
        ensure   => $ensure_real,
        content  => template($template_upstream),
      }
    }
  }
}
