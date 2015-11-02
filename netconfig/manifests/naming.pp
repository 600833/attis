class netconfig::naming ( $stage = main )
{
	file
	{ 'resolv.conf':
		ensure=> present,
		path=> "/etc/resolv.conf",
		mode=> "0644",
		owner=> root,
		group=> root,
		content=> template("netconfig/resolv.conf.erb"),
		require=> Service['network'],
	}
	file
	{ 'hosts':
	 	ensure=> present,
		path=> '/etc/hosts',
		mode=> '0644',
		owner=> root,
		group=> root,
		content=> template('netconfig/hosts.erb'),
		require=> File['resolv.conf'],
	}
}
