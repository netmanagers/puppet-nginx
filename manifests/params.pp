# Class: nginx::params
#
# This class defines default parameters used by the main module class nginx
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to nginx class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class nginx::params {

  $gzip = 'on'
  $worker_connections = 1024
  $multi_accept = 'on'
  $keepalive_timeout = 65
  $client_max_body_size = '10m'
  $server_names_hash_max_size = 512
  $server_names_hash_bucket_size = 64
  $types_hash_max_size = 1024
  $sendfile = 'on'

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'nginx',
  }

  $service = $::operatingsystem ? {
    default => 'nginx',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $service_restart = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'nginx',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'www-data',
    default => 'nginx',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/nginx',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/nginx/nginx.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/nginx',
    default                   => '/etc/sysconfig/nginx',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/nginx.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/usr/share/nginx/html',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/nginx',
  }

  $log_file = $::operatingsystem ? {
    default => [ '/var/log/nginx/access.log' , '/var/log/nginx/error.log' ]
  }

  $port = '80'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $config_file_default_purge = false
  $template = ''
  $options = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false

}
