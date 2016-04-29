class netservices::firewalld ($stage = 'main', $service_ensure = 'running',$zone_interface={} ) {
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
    $installed_zones = '/usr/lib/firewalld/zones'
    $unit_file = '/etc/systemd/system/firewalld.service' 
    $foreman_interfaces.each  |$v| {
      notify{"interface $v":}
      if $v['provision'] {
       sauver("adm_nic",$v['identifier'])
      }
      if $v['primary'] {
       sauver("prod_nic",$v['identifier'])
      }
    }
    $adm_nic=restaurer("adm_nic")
    $prod_nic=restaurer("prod_nic")
    if $adm_nic == $prod_nic {
      $prod_list="${fwd_prod};${fwd_adm}"
      $adm_list="" 
    }
    else {
      $prod_list=$fwd_prod
      $adm_list=$fwd_adm
    }
    $zone_interface.each |$k,$v| {
     sauver($k,$v)
     sauver("ent_list",$k)
    }
    if restaurer($adm_nic)==undef {
     sauver($adm_nic,$adm_list)
     sauver("ent_list",$adm_nic)
    }
    else {
     sauver($adm_nic,";$adm_list",add)
    }
    if restaurer($prod_nic)==undef {
     sauver($prod_nic,$prod_list)
     sauver("ent_list",$prod_nic)
    }
    else {
     sauver($prod_nic,";$prod_list",add)
    }
    $ent_list_1=restaurer("ent_list")
    if is_string($ent_list_1) {
     $ent_list=[$ent_list_1]
    }
    else {
     $ent_list=$ent_list_1
    } 
    notify {"ent_list $ent_list":}
#    notify{"liste nic $ent_list":}
    $ent_list.each |$v| {
     $x=restaurer($v)
     notify {"ports de $v":message=>$x}
    }
#
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
  file { "untrusted":
    path     => "${zones_dir}/${projet_prefix}_untrusted.xml",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => '0644',
    content  => template("netservices/firewalld/untrusted_zone.xml.erb"),
    notify   =>  Service[$service_name]
  }
  $interface_liste=split($interfaces,'[,;]')
#  notify{"real nic":message=>$interface_liste}
  $ent_list.each | $zone | {
    $fwd_srv=restaurer($zone)
    $nom_fichier=regsubst($zone,"[:.]","_","G")
    if $nom_fichier in $interface_liste {
     file { $zone:
       path     => "${zones_dir}/${projet_prefix}_${nom_fichier}.xml",
       ensure   => file,
       owner    => 0,
       group    => 0,
       mode     => '0644',
       content  => template("netservices/firewalld/zone.xml.erb"),
       notify   =>  Service[$service_name]
     }
    }
  }
  $fwservices2=hiera("fwservices2")
  $ar_fwd_adm = split($fwd_adm,"[;, ]")
  $ar_fwd_prod = split($fwd_prod,"[;, ]")
  sauver("srvlist",$fwd_adm)
  sauver("srvlist",";${fwd_prod}","add")
  $zone_interface.each |$k,$v| {
   sauver("srvlist",";${v}","add")
  }
  $srvlist=restaurer("srvlist")
  $srvlist1=unique(itemize2array($srvlist))
#  notify{"liste service $srvlist1 ":}
  $srvlist1.each |$sv| {
     if ( $fwservices[$sv] == undef and  $sv !~ /^port=/ ) {
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
