class netservices::sudo ( $stage = main )
{
	package {'sudo':
		ensure=> installed,
	}
	file { '/etc/sudoers':
		owner=> root,
		group=> root,
		mode=> '0440',
		ensure=> present,
		content=> template('netservices/sudoers.erb'),
		require=> Package['sudo'],
	}
	file { '/etc/sudoers.d':
		owner=> root,
		group=> root,
		mode=> '0750',
		ensure=> directory,
		require=> Package['sudo'],
	}
}
