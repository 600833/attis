class netservices::firewalld ($stage = 'main', $service_ensure = 'running' ) {
    $config_dir = '/etc/firewalld'
    $configfile = 'firewalld.conf'
    $services_dir = "$config_dir/services"
    $zones_dir = "$config_dir/zones"
    $log_dir = '/var/log'
    $service_enable = true
    $package_name = 'firewalld'
    $service_hasstatus = true
    $service_name = 'firewalld.service'
    $projet_prefix = 'iss'
    $default_zone = 'untrusted'
    $zone_list = ['untrusted','adm','prod']
    $installed_zones = '/usr/lib/firewalld/zones'
    $unit_file = '/etc/systemd/system/firewalld.service' 
    

  package { $package_name:
    ensure=> installed,
  }
  file { $configfile:
    path     => "$config_dir/$configfile",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => '0644',
    content  => template("netservices/firewalld/${configfile}.erb"),
    notify   => Service[$service_name],
  }
  file { $zones_dir:
    ensure => directory,
    recurse => true,
    purge => true,
    force => true,
    owner => 0,
    group => 0,
    mode => '0750',
  }
  file { $services_dir:
    ensure=> directory,
    recurse=> true,
    purge=> true,
    force=> true,
    owner=> 0,
    group=> 0,
    mode=> '0750',
  }
  $zone_list.each | $zone | {
    file { $zone:
       path     => "${zones_dir}/${projet_prefix}_${zone}.xml",
       ensure   => file,
       owner    => 0,
       group    => 0,
       mode     => '0644',
       content  => template("netservices/firewalld/zone.xml.erb"),
       notify   =>  Service[$service_name]
    }
  }
  $fwservices2=hiera("fwservices2")
  $ar_fwd_adm = split($fwd_adm,";")
  $ar_fwd_prod = split($fwd_prod,";")
  $ar_fwd_prod.each |$sv| {
     if $fwservices[$sv] == undef {
     file { "${services_dir}/${sv}.xml":
	ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644', 
        content => template("netservices/firewalld/fwservice.xml.erb"),
        notify   =>  Service[$service_name]
    } 
    }
  }
  $ar_fwd_adm.each |$sv| {
     if $fwservices[$sv] == undef {
     file { "${services_dir}/${sv}.xml":
	ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644', 
        content => template("netservices/firewalld/fwservice.xml.erb"),
        notify   =>  Service[$service_name]
    } 
    }
  }
  file { $unit_file:
	ensure => present,
	owner => root,
	group => root,
	mode  => '0644',
        content => template("netservices/firewalld/firewalld.service.erb"),
	notify => Exec["reinstall_firewalld"],
  }
  exec { "reinstall_firewalld":
	path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
        command=> "/bin/systemctl disable firewalld;/bin/systemctl enable firewalld; systemctl daemon-reload",
        refreshonly => true,
        logoutput => true,
	notify => Service[$service_name],
  }
  service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => $service_hasstatus,
      hasrestart => true,
      require    => [Package[$package_name],Service['dbus.service']],
   }
   service { 'dbus.service' :
       name       => 'dbus.service',
       ensure     => 'running',
       enable     => true,
   }
}
