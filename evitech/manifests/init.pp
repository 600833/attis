# == Class: evitech
#
# Full description of class evitech here.
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
#  class { 'evitech':
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
class evitech($stage='main',$user_list) {
 $additional_packages="gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts"
 $v_additional_packages=itemize2array($additional_packages)
 package { 'tigervnc-server':
  ensure=> installed,
 }

 package {$v_additional_packages: ensure=> installed}

 $array_user_list = itemize2array($user_list)
 $array_user_list.each |$ind,$el| {
  user { $el :
   ensure=> present,
   managehome=> true,
  }
  file { "/etc/systemd/system/vncserver@:${$ind + 1}.service":
   ensure=> present,
   content=> template("${module_name}/vncserver_conf.erb"),
   owner=> 0,
   group=> 0,
   mode=> '644',
  }
  file {"/home/$el/.vnc":
   ensure=> directory,
   owner=> $el,
   group=> $el,
   mode=> '755',
  }
  file {"/home/$el/.vnc/passwd":
   ensure=> present,
   owner=> $el,
   group=> $el,
   mode=> '600',
   source=> "puppet:///modules/$module_name/vnc_passwd",
  }
  service {"vncserver@:${$ind + 1}.service":
   ensure=> running,
   enable=> true,
  }
 }
}
