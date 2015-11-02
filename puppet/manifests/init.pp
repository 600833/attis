# == Class: config puppet master and client
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
#
#
# === Authors
#
# Victor LI
#
#
class puppet (
  $stage = main,
  $runinterval  = $puppet::params::runinterval,
  $listen = $puppet::params::listen,
  $polling = $puppet::params::polling
) inherits puppet::params {
  validate_string($runinterval)
  validate_bool($listen)
  validate_bool($polling)
  include puppet::install
  include puppet::config
  include puppet::service
  
}
