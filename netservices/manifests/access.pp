class netservices::access ( $stage = 'main' )
{
	$package_name = 'pam'
	$access_conf = '/etc/security/access.conf'
	$access_conf_erb = 'access_conf.erb'
	$enable_conf = 'enable_access'
	
	package { $package_name:
		ensure=> present,
	}	
	file { $access_conf:
		ensure=> present,
		owner=> 0,
		group=> 0,
		mode=> '0644',
		content=> template("netservices/${access_conf_erb}"),
		require=> Package[$package_name],
		notify=> Exec[$enable_conf],
	}
	exec { $enable_conf:
		refreshonly=> true,
		path=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
		command=> 'authconfig --enablepamaccess --update',
	}
}
