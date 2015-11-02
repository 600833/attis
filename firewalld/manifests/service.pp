class firewalld::service inherits firewalld {
  if ! ($service_ensure in [ 'running', 'stopped' ]) {
    fail('service_ensure parameter must be running or stopped')
  }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => $service_name,
      hasstatus  => $service_hasstatus,
      hasrestart => true,
      require    => [Package[$package_name],Service['dbus.service']],
#      require  => Exec['restart_dbus.service'],
    }
#   exec { 'restart_dbus.service' :
#      command     => 'systemctl restart dbus.service',
#      path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin',
#      refreshonly => true,
#      before => Service [$service_name],
#   }
   service { 'dbus.service' :
       name       => 'dbus.service',
       ensure     => 'running',
       enable     => true,
   }
}
