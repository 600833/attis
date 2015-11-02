class puppet::install inherits puppet {
  package { 'puppet':
    ensure => $package_ensure,
    name   => $package_name,
    notify => Service[$service_name],
  }
}
