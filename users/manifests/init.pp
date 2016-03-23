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
class users ($stage='main',$grplist={},$userlist={}) {
 unless is_hash($userlist) {
  fail("${userlist} is not hash type")
 }

 unless is_hash($grplist) {
  fail("${grp_list} is not hash type")
 }
 
# notify {"userlist": message=>"${userlist}"}
# notify {"grplist": message=>"${grp_list}"}
#
#create group
#
 $grplist.each |$k,$v| {
  $v1=split($v,':')
  $etat=strip($v1[0])
  $nom=strip($k)
  $id_group=strip($v1[3])
  group {$nom:
   ensure=> $etat,
   gid=> $id_group,
  }
 }
#
#create private group and user
#
 $userlist.each |$k,$v| {
  $v1=split($v,':')
  $etat=strip($v1[0])
  $nom=strip($k)
  $tmp_mdp=strip($v1[2])
  if $tmp_mdp =~ /^\$[0-9]\$/ {
   $mdp=$tmp_mdp
  }
  else {
   $mdp=pw_hash($tmp_mdp,"SHA-256","puppet")
  }
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

