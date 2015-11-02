class firewalld::install inherits firewalld {
  package { 'firewalld':
    ensure => $package_ensure,
    name   => $package_name,
#    notify => Exec['restart_dbus.service'],
    notify => Service['dbus.service'],
  }
  notice ("package_ensure = $package_ensure")
}
