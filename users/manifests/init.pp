# == Class: users
#
# Full description of class users here.
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
#  $user_lst : user list 
#  $group_lst : group list 
#  $stage : run stage 
#   
#   
#
# === Examples
#
#  class { 'users':
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
class users ($stage='main', $user_lst=[], $group_lst=[]) {
 unless is_array($user_lst) {
  fail("${user_lst} is not array type")
 }

 unless is_array($group_lst) {
  fail("${group_lst} is not array type")
 }
 
# notify {"user_list": message=>"${user_lst}"}
# notify {"group_list": message=>"${group_lst}"}
#
#create group
#
 $group_lst.each |$v| {
  $v1=split($v,':')
  $etat=strip($v1[0])
  $nom=strip($v1[1])
  $id_group=strip($v1[3])
  group {$nom:
   ensure=> $etat,
   gid=> $id_group,
  }
 }
#
#create private group and user
#
 $user_lst.each |$v| {
  $v1=split($v,':')
  $etat=strip($v1[0])
  $nom=strip($v1[1])
  $mdp=strip($v1[2])
  $id_user=strip($v1[3])
  $id_group=strip($v1[4])
  $desc=strip($v1[5])
  $maison=strip($v1[6])
  $xshell=strip($v1[7])
  $mb1=strip($v1[8])
  $mb2=split($mb1,'[,;]')
  group {$nom:
   ensure=> $etat,
   gid=> $id_group,
  }
  user {$nom:
   ensure=> $etat,
   comment=> $desc,
   gid=> $id_group,
   home=> $maison,
   password=> $mdp,
   shell=> $xshell,
   uid=> $id_user,
   managehome=> true,
   groups=> $mb2,
  }
 }
}

