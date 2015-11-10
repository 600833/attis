class foreman::signcert ($stage = 'main')
{
	cron {'sign_cert':
		ensure=> present,
		command=> 'puppet cert sign --allow-dns-alt-names --all >>/var/log/puppet_cert_sign.out 2>&1',
		user=> root,
		environment=> 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
		minute=> '*',
	}
}
