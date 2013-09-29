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
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  $file_real = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => "${nginx::config_dir}/sites-available/${vhost}.conf",
    default                   => "${nginx::config_dir}/conf.d/${vhost}.conf",
  }

  ## Check for various error condtiions
  if ($vhost == undef) {
    fail('Cannot create an upstream reference without attaching to a virtual host')
  }

  concat::fragment { "${vhost}+105-upstream.tmp":
    ensure  => $ensure_real,
    order   => '105',
    content => template($template_upstream),
    target  => $file_real,
    notify  => $nginx::manage_service_autorestart,
  }
}
