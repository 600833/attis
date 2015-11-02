class netservices::autofs ($stage = 'main',$mnt = '/exports', $homeserver = 'homeserver')
{
	$package_lst=['autofs','nfs-utils']
	$service_name='autofs.service'
	package {$package_lst:
		ensure=> installed,
		notify=> Service[$service_name],
	}
	file {$mnt:
		ensure=> directory,
		owner=> 0,
		group=> 0,
		mode=> '0755',
		path=> $mnt,
		require=> Package[$package_lst],
	}
	file {'/etc/auto.master':
		ensure=> present,
		owner=> 0,
		group=> 0,
		mode=> '0644',
		content=> template('netservices/auto.master.erb'),
		require=> Package[$package_lst],
		notify=> Service[$service_name],
	}
	file {'/etc/auto.exports':
		ensure=> present,
		owner=> 0,
		group=> 0,
		mode=> '0644',
		content=> template('netservices/auto.exports.erb'),
		require=> Package[$package_lst],
		notify=> Service[$service_name],
	}
	service {$service_name:
		ensure=> running,
		enable=> true,
		require=> Package[$package_lst],
	}
}
