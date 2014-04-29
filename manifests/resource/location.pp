# define: nginx::resource::location
#
# This definition creates a new location entry within a virtual host
#
# Parameters:
#   [*ensure*]             - Enables or disables the specified location (present|absent)
#   [*vhost*]              - Defines the default vHost for this location entry to include with
#   [*location*]           - Specifies the URI associated with this location entry
#   [*www_root*]           - Specifies the location on disk for files to be read from. Cannot be set in conjunction with $proxy
#   [*redirect*]           - Specifies a 301 redirection. You can either set proxy, www_root or redirect.
#                            The request_uri is automatically appended. Usage example: redirect => 'http://www.example.org'
#   [*index_files*]        - Default index files for NGINX to read when traversing a directory
#   [*proxy*]              - Proxy server(s) for a location to connect to. Accepts a single value, can be used in conjunction
#                            with nginx::resource::upstream
#   [*proxy_read_timeout*] - Override the default the proxy read timeout value of 90 seconds
#   [*ssl*]                - Indicates whether to setup SSL bindings for this location.
#   [*mixin_ssl*]          - Indicates whether SSL directive is to be put into the same file (only for backward compatibility)
#   [*limit_except*]       - Specifies that auth requests should be enclosed within a limit_except
#   [*auth_basic_user_file*] - auth_basic_user_file location
#   [*auth_basic*]         - auth_basic message
#   [*option*]             - Reserved for future use
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::location { 'test2.local-bob':
#    ensure   => present,
#    www_root => '/var/www/bob',
#    location => '/bob',
#    vhost    => 'test2.local',
#  }
define nginx::resource::location(
  $ensure             = present,
  $vhost              = undef,
  $limit_except       = undef,
  $auth_basic_user_file = undef,
  $auth_basic          = undef,
  $www_root           = undef,
  $create_www_root    = false,
  $owner              = '',
  $groupowner         = '',
  $redirect           = undef,
  $index_files        = ['index.html', 'index.htm', 'index.php'],
  $proxy              = undef,
  $proxy_read_timeout = '90',
  $proxy_set_header   = ['Host $host', 'X-Real-IP $remote_addr', 'X-Forwarded-For $proxy_add_x_forwarded_for', 'X-Forwarded-Proto $scheme' ],
  $proxy_redirect     = undef,
  $ssl                = false,
  $ssl_only           = false,
  $option             = undef,
  $mixin_ssl          = undef,
  $template_ssl_proxy = 'nginx/vhost/vhost_location_proxy.erb',
  $template_proxy     = 'nginx/vhost/vhost_location_proxy.erb',
  $template_directory = 'nginx/vhost/vhost_location_directory.erb',
  $template_redirect  = 'nginx/vhost/vhost_location_redirect.erb',
  $location           = $title
) {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => $nginx::manage_service_autorestart,
  }

  $bool_create_www_root = any2bool($create_www_root)
  $bool_ssl_only = any2bool($ssl_only)

  $real_owner = $owner ? {
    ''      => $nginx::config_file_owner,
    default => $owner,
  }

  $real_groupowner = $groupowner ? {
    ''      => $nginx::config_file_group,
    default => $groupowner,
  }

  ## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => present,
  }

  $file_real = "${nginx::vdir}/${vhost}.conf"

  # Use proxy template if $proxy is defined, otherwise use directory template.
  if ($proxy != undef) {
    $content_real     = template($template_proxy)
    $content_ssl_real = template($template_ssl_proxy)
  } else {
    if ($redirect != undef) {
      $content_real = template($template_redirect)
    } else {
      $content_real     = template($template_directory)
      $content_ssl_real = template($template_directory)
    }
  }

  ## Check for various error condtiions
  if ($vhost == undef) {
    fail('Cannot create a location reference without attaching to a virtual host')
  }
  if (($www_root == undef) and ($proxy == undef) and ($redirect == undef)) {
    fail('Cannot create a location reference without a www_root, proxy or redirect defined')
  }
  if (($www_root != undef) and ($proxy != undef)) {
    fail('Cannot define both directory and proxy in a virtual host')
  }
  if (($www_root != undef) and ($redirect != undef)) {
    fail('Cannot define both directory and redirect in a virtual host')
  }
  if (($proxy != undef) and ($redirect != undef)) {
    fail('Cannot define both proxy and redirect in a virtual host')
  }
  if (($auth_basic_user_file != undef) and ($auth_basic == undef)) {
    fail('Cannot define auth_basic_user_file without auth_basic')
  }
  if (($auth_basic_user_file != undef) and ($auth_basic == undef)) {
    fail('Cannot define auth basic without a user file')
  }

  if $bool_create_www_root == true {
    file { $www_root:
      ensure => directory,
      owner  => $real_owner,
      group  => $real_groupowner,
    }
  }


  ## Create stubs for vHost File Fragment Pattern
  if $bool_ssl_only != true {
    concat::fragment { "${vhost}+50-${location}.tmp":
      ensure  => $ensure_real,
      order   => '50',
      content => $content_real,
      target  => $file_real,
    }
  }

  if ($mixin_ssl) {
    ## Only create SSL Specific locations if $ssl is true.
    concat::fragment { "${vhost}+80-ssl-${location}.tmp":
      ensure  => $ssl,
      order   => '80',
      content => $content_ssl_real,
      target  => $file_real,
    }
  }
}
