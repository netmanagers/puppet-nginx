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

  $process = $::operatingsystem ? {
    default => 'nginx',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
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
  $source_dir_purge = ''
  $template = ''
  $options = ''
  $service_autorestart = true
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
