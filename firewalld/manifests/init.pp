# == Class: firewall
#
# Manages the firewall daemon.
#
# === Parameters
#
# Document parameters here.
#
# [*config_dir*]
#   Restrict the network interface to which chronyd will listen for command
#   packets (issued by chronyc).
#   Default: [ '127.0.0.1', '::1' ]
#
# [*services_dir*]
#   Designate subnets from which NTP clients are allowed to access the
#   computer as an NTP server. IPv4 and IPv6 CIDR ranges can be specified.
#   Default: []
#
# [*zones_dir*]
#   Designate subnets within previously allowed subnets which are denied
#   to access the NTP server. IPv4 and IPv6 CIDR ranges can be specified.
#   Default: []
#
# [*log_dir*]
#   Whether to log statistics about NTP clients.
#   Default: false
#
# [*package_ensure*]
#   Whether the NTP client should start in offline mode. In this mode, clients
#   must issue the chronyc online command to begin synchronization (though
#   most systems with a GUI will manage to do this automatically). Useful for
#   laptops and other intermittently connected devices.
#   Default: false
#
#
#
# === Authors
#
# Victor LI
#
#
class firewalld (
  $package_ensure    = $firewalld::params::package_ensure,
  $service_ensure    = $firewalld::params::service_ensure,
  $projet_prefix     = $firewalld::params::projet_prefix,
  $service_enable    = $firewalld::params::service_enable,
  $zone2_source_list = $firewalld::params::zone2_source_list,
  $zone3_source_list = $firewalld::params::zone3_source_list,
  $zone3_service_list= $firewalld::params::zone3_service_list
) inherits firewalld::params {
  validate_string($package_ensure)
  validate_string($service_ensure)
  validate_absolute_path($config_dir)
  validate_absolute_path($services_dir)
  validate_absolute_path($zones_dir)
  validate_absolute_path($log_dir)
  validate_string($package_name)
  validate_bool($service_hasstatus)
  validate_string($service_name)
  validate_string($projet_prefix)
  validate_string($configfile)
  validate_bool($service_enable)
  validate_array($zone2_source_list)
  validate_array($zone3_source_list)
  validate_array($zone3_service_list)

  anchor { 'firewalld::begin': } ->
  class { '::firewalld::install': } ->
  class { '::firewalld::config': } ->
  class { '::firewalld::service': } ->
  anchor { 'firewalld::end': }
}
