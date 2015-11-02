class puppet::params {
  $package_name     = 'puppet'
  $package_ensure   = 'present'
  $service_ensure   = 'running'
  $service_enable   = true
  $service_name     = 'puppet'
  $runinterval = '1h'
  $listen = true
  $puppet_config = '/etc/puppet/puppet.conf'
  $puppet_auth = '/etc/puppet/auth.conf'
  $polling = true 
  $puppetagent_option_file = '/etc/sysconfig/puppetagent'

  case $::operatingsystem {
    'Archlinux': {
    }
    'Debian': {
    }
    /(CentOS|RedHat)/: {
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::operatingsystem} distribution.")
    }
  }
}
