class mco::server inherits mco {
  package { $package_name :
    ensure => $package_ensure,
    before => Service[$server_service_name]
  }
  package { "${package_name}-service-agent":
    ensure => $package_ensure,
    before => Service[$server_service_name]
  }
  package { "${package_name}-puppet-agent":
    ensure => $package_ensure,
    before => Service[$server_service_name]
  }
  service { $server_service_name :
    ensure => $service_ensure,
    enable => $service_enabled
  }
  file { server_public:
    ensure => present,
    source => "puppet:///modules/${module_name}/mcollective-servers.pem",
    path => "${server_config_dir}/server_public.pem",
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  notify => Service[$server_service_name]
  }
  file { server_private:
    ensure => present,
    source => "puppet:///modules/${module_name}/mcollective-servers.key",
    path => "${server_config_dir}/server_private.pem", 
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify => Service[$server_service_name]
  }
  file { clients :
    ensure => directory,
    path => "${server_config_dir}/clients",
    recurse => true,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => "puppet:///modules/${module_name}/clients",
    notify => Service[$server_service_name]
  }
  file { facts_yaml:
    owner    => 'root',
    group    => 'root',
    mode     => '0400',
    path => "${server_config_dir}/facts.yaml",
    loglevel => debug, # reduce noise in Puppet reports
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
  }
  file { server_config:
    owner   => root,
    group   => root,
    mode    => 0400,
    path    => "${server_config_dir}/${server_config}",
    content => template("${module_name}/${server_config}.erb"),
    notify  => Service[$server_service_name]
  }
}
