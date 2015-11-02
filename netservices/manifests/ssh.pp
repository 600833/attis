class netservices::ssh ( $stage = main )
{
	package {['openssh-server','openssh-clients']:
		ensure=> installed,
	}
	file { '/etc/ssh/sshd_config':
		owner=> root,
		group=> root,
		mode=> '0600',
		ensure=> present,
		content=> template('netservices/ssh/sshd_config.erb'),
		require=> Package['openssh-server','openssh-clients'],
		notify=> Service['sshd'],
	}
	file { ['/etc/issue','/etc/issue.net']:
		owner=> root,
		group=> root,
		mode=> '0644',
		ensure=> present,
		content=> template('netservices/ssh/banner.erb'),
	}
	service {'sshd':
		ensure=> running,
		enable=> true,
	}
}
