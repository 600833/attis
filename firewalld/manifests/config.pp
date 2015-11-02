class firewalld::config inherits firewalld {
  file { $configfile:
    path     => "$config_dir/$configfile",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => 0644,
    content  => template("firewalld/${configfile}.erb"),
    notify   => Service[$service_name],
  }
  file { $zones_dir :
    ensure => directory,
    recurse => true,
    purge => true,
    force => true,
    owner => 0,
    group => 0,
    mode => 0750, 
  }
  file { $zone1:
    path     => "${zones_dir}/${projet_prefix}_${zone1}.xml",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => 0644, 
    content  => template("firewalld/${zone1}.xml.erb"),
    notify   =>  Service[$service_name]
  }
  file { $zone2:
    path     => "${zones_dir}/${projet_prefix}_${zone2}.xml",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => 0644, 
    content  => template("firewalld/${zone2}.xml.erb"),
    notify   =>  Service[$service_name]
  }
  file { $zone3:
    path     => "${zones_dir}/${projet_prefix}_${zone3}.xml",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => 0644, 
    content  => template("firewalld/${zone3}.xml.erb"),
    notify   =>  Service[$service_name]
  }
}
