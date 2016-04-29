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
class lvm2::fs ($stage='main', $fs_list, $ismount) {
 if ! is_hash($fs_list) {
  fail("${fs_list} is not hash type")
 }
 $fs_list1=hash_sort_by_keys($fs_list)
 $fs_list1.each |$k,$v| {
  $vec=itemize2array($v)
  $mnt_point=$k
  $mnt_device=$vec[0]
  $taille=$vec[1]
  if empty($taille) { fail("taille du fs n'est pas renseigné") }
  if empty($mnt_point) { fail("point de montage du fs n'est pas renseigné") }
  if empty($mnt_device) { fail("volume logique du fs n'est pas renseigné") }
  filesystem {"$mnt_point":
   ensure=> present,
   device=>"${mnt_device}",
   size=> "${taille}",
   fstype=> 'ext4',
#   owner=> 0,
#   group=> 0,
   owner=> $install_user,
   group=> $install_group,
   mode=> '755',
   mnt_options=> 'rw',
   mount=> $ismount,
#   notify=>Mount[$mnt_point],
  }
#  mount {"${mnt_point}":
#   ensure=> 'mounted',
#   device=> "${mnt_device}",
#   fstype=> 'ext4',
#   options => 'defaults',
#   pass => '2',
#   target=> '/etc/fstab',
#  }
 }
}
