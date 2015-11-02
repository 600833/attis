class firewalld::params {

  $package_ensure   = '0.3.9-11.el7'
  $service_ensure   = 'running'
  $service_enable   = true

  case $::operatingsystem {
    'Archlinux': {
    }
    'Debian': {
    }
    /(CentOS|RedHat)/: {
      $config_dir = '/etc/firewalld'
      $services_dir = "$config_dir/services"
      $zones_dir = "$config_dir/zones"
      $log_dir = '/var/log'
      $package_name = 'firewalld'
      $service_hasstatus = true
      $service_name = 'firewalld.service'
      $projet_prefix = 'iss'
      $configfile = 'firewalld.conf'
      $zone1 = 'untrusted'
      $zone2 = 'trusted'
      $zone3 = 'limited'
      $default_zone = $zone1
      $zone2_source_list = ["192.168.111.4/32","192.168.111.7/32"]
      $zone3_source_list = ["192.168.111.1/32"]
      $zone3_service_list = ["ssh","http"]
      $installed_zones = '/usr/lib/firewalld/zones'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::operatingsystem} distribution.")
    }
  }
}
