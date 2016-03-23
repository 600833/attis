# == Class: sys_conf
#
# Full description of class sys_conf here.
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
#  class { 'sys_conf':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class sys_conf::reboot_stg05($stage='STG05') {
 exec {"reboot_stg05":
  path=> '/sbin:/bin',
  command=> 'echo "(date;sleep 30;systemctl reboot) > /tmp/reboot.log 2>&1"|at now',
  refreshonly=> true,
 } 
}
class sys_conf($stage="main",$conf_list={}) {
 include sys_conf::reboot_stg05
 $reboot='reboot_stg05'
 unless is_hash($conf_list) {
  fail('$conf_list is not valid hash')
 } 
 $conf_list.each |$ky,$val | {
  $val2=split($val,";")
  if empty($val2[0]) {
   $u='root'
  }
  else {
   $u=strip($val2[0])
  }
  if empty($val2[1]) {
   $g='root'
  }
  else {
   $g=strip($val2[1])
  }
  if empty($val2[2]) {
   $m='622'
  }
  else {
   $m=strip($val2[2])
  }
 $f=strip($val2[3])
 $bt=strip($val2[4])
  if $f =~ /\.erb$/ {
   if (empty($bt) == false) and ($bt in 'bB') {
    file {$ky:
     ensure=> present,
     owner=> $u,
     group=> $g,
     mode=> $m,
     content=> template("${module_name}/${f}"),
     notify=> Exec[$reboot] 
    }
   }
   else {
    file {$ky:
     ensure=> present,
     owner=> $u,
     group=> $g,
     mode=> $m,
     content=> template("${module_name}/${f}"),
    }
   }
  }
  else {
   if (empty($bt) == false ) and ($bt in 'bB') {
    file {$ky:
     ensure=> present,
     owner=> $u,
     group=> $g,
     mode=> $m,
     source=> "puppet:///modules/${module_name}/${f}",
     notify=> Exec[$reboot]
    }
   }
   else {
    file {$ky:
     ensure=> present,
     owner=> $u,
     group=> $g,
     mode=> $m,
     source=> "puppet:///modules/${module_name}/${f}",
    }
   }
  }
 }
}
