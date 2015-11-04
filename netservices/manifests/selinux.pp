class netservices::selinux( $stage='main',$selinux_mode='enforcing')
{
	$selinu_config_file="/etc/selinux/config"
	file {$selinu_config_file:
		ensure=> present,
		content=> template("${module_name}/selinux_config.erb"),
		group=> 0,
		owner=> 0,
		mode=> '644',
	}
	case $selinux_mode { 
	'enforcing': { $val=1 }
	'permissive': { $val=0 }
	default: {$val=1 }
	}
	if $selinux_current_mode != $selinux_mode {
	exec { 'set_selinux':
		path=> '/sbin:/bin',
		logoutput=> true,
		command=> "setenforce ${val}",
	}}
}
