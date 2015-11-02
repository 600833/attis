class netservices::chrony ( $stage = main )
{
	File {
		owner=> root,
		group=> root,
		mode=> '644',
		ensure=> present,
	}
	file {'chrony.conf':
		path=> '/etc/chrony.conf',
		content=> template('netservices/chrony.conf.erb'),
		notify=>Service['chronyd'],
	}
	service {'chronyd':
		enable=> true,
		status=> running,
	}
}
