# == Class: lvm2
#
# Full description of class vli here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'vli':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class lvm2 ($stage='main', $fs_list) {
 $fs=$fs_list
# $vfs=inline_template("<%= @fs.split(/[;, ]+/) %>")
 notify{"${fs}": }
# notify{"${$vfs[1]}": }
# notify{"${$vfs[2]}": }
# filesystem {"${vfs[0]}":
#  ensure=> present,
#  device=>"${vfs[1]}",
#  size=> "${vfs[2]}",
#  fstype=> 'ext4',
#  owner=> root,
#  group=> root,
#  mnt_options=> 'rw',
#  mount=> true,
# }
}
