# define: nginx::resource::upstream
#
# This definition creates a new upstream proxy entry for NGINX
#
# Parameters:
#   [*ensure*]      - Enables or disables the specified location (present|absent)
#   [*members*]     - Array of member URIs for NGINX to connect to. Must follow valid NGINX syntax.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::upstream { 'proxypass':
#    ensure  => present,
#    members => [
#      'localhost:3000',
#      'localhost:3001',
#      'localhost:3002',
#    ],
#  }
define nginx::resource::upstream (
  $members,
  $ensure            = present,
  $template_upstream = 'nginx/conf.d/upstream.erb',
) {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $real_file = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  file { "${nginx::cdir}/${name}-upstream.conf":
    ensure   => $real_file,
    content  => template($template_upstream),
    notify   => $nginx::manage_service_autorestart,
    require  => Package['nginx'],
  }
}
