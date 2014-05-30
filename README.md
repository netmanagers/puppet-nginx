# Puppet module: nginx

This is a Puppet nginx module from the second generation of Example42 Puppet Modules.

Made by

  * Alessandro Franceschi / Lab42

Maintainer

  * Javier Bertoli / Netmanagers

The nginx::resource:: classes and relevant code has been derived from https://github.com/zertico/puppetlabs-nginx.git
which is a fort of James Fryman /PuppetLabs original nginx module

Official site: http://www.example42.com

Official git repository: http://github.com/netmanagers/puppet-nginx

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module.

For detailed info about the logic and usage patterns of Example42 modules read README.usage on Example42 main modules set.

## USAGE - Basic management

* Install nginx with default settings

        class { "nginx": }

* Install nginx with some useful settings

        class { "nginx":
          worker_connections => 4096, # the default value 1024 cannot match the needs of a large site
          keepalive_timeout => 120, # increase this according to your app's responde time
          client_max_body_size => '200m', # increase this while your nginx works as an upload server.
        }

* Disable nginx service.

        class { "nginx":
          disable => true
        }

* Disable nginx service at boot time, but don't stop if is running.

        class { "nginx":
          disableboot => true
        }

* Remove nginx package

        class { "nginx":
          absent => true
        }

* Enable auditing without without making changes on existing nginx configuration files

        class { "nginx":
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file

        class { "nginx":
          source => [ "puppet:///modules/lab42/nginx/nginx.conf-${hostname}" , "puppet:///modules/lab42/nginx/nginx.conf" ],
        }


* Use custom source directory for the whole configuration dir

        class { "nginx":
          source_dir       => "puppet:///modules/lab42/nginx/conf/",
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file

        class { "nginx":
          template => "example42/nginx/nginx.conf.erb",
        }

* Define custom options that can be used in a custom template without the
  need to add parameters to the nginx class

        class { "nginx":
          template => "example42/nginx/nginx.conf.erb",
          options  => {
            'LogLevel' => 'INFO',
            'UsePAM'   => 'yes',
          },
        }

* Automaticallly include a custom subclass

        class { "nginx:"
          my_class => 'nginx::example42',
        }


## USAGE - Example42 extensions management
* Activate puppi (recommended, but disabled by default)
  Note that this option requires the usage of Example42 puppi module

        class { "nginx":
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with
  a puppi::helper define ) to customize the output of puppi commands

        class { "nginx":
          puppi        => true,
          puppi_helper => "myhelper",
        }

* Activate automatic monitoring (recommended, but disabled by default)
  This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { "nginx":
          monitor      => true,
          monitor_tool => [ "nagios" , "monit" , "munin" ],
        }

* Activate automatic firewalling
  This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { "nginx":
          firewall      => true,
          firewall_tool => "iptables",
          firewall_src  => "10.42.0.0/24",
          firewall_dst  => "$ipaddress_eth0",
        }

## USAGE - VirtualHost

You have 2 different options to manage virtual hosts

* Use the nginx::vhost define, whose logic and parameters are similar to Example42 apache::vhost
  and where you have to set your docroot and eventually a custom template to use:

        nginx::vhost { 'mydomain.com' :
          template => 'myproject/nginx/mydomain/nginx.conf.erb',
          docroot  => '/var/www/mydomain',
        }

* Use the nginx::resource::vhost define which has been ported from puppetlabs/nginx module
  and it provides more flexibility in the management of virtual hosts and single location
  statements (with the nginx::resource::location define).

* Templates used by nginx::resource can be overriden

        nginx::resource::vhost { 'mydomain.com' :
          www_root        => '/var/www/mydomain',
          template_header => 'my_module/nginx/header.erb',
        }

* You can add additional locations for special handling like redirect:

        nginx::resource::location {"www.example.org-wiki":
          ensure             => present,
          vhost              => 'www.example.org',
          location           => '/wiki',
          redirect           => 'http://wiki.example.org'
        }

[![Build Status](https://travis-ci.org/netmanagers/puppet-nginx.png?branch=master)](https://travis-ci.org/netmanagers/puppet-nginx)
