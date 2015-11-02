class puppet::service inherits puppet {
  if ! ($service_ensure in [ 'running', 'stopped' ]) {
    fail('service_ensure parameter must be running or stopped')
  }
    exec {'restart_puppet':
           command => 'echo "systemctl restart puppet"  | at now + 5min',
           refreshonly => true,
           path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin'
  }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => $service_name,
      hasstatus  => true,
      hasrestart => true,
      require    => [Package[$package_name]],
    }
}
