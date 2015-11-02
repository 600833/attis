class netservices::ad ( $stage = 'main' )
{
	$pkg_lst= ['sssd','adcli','krb5-workstation','oddjob-mkhomedir','openldap-clients']
	$sssd_conf= "/etc/sssd/sssd.conf"
        $foreman_keytab= "/etc/sssd/foreman.keytab"
        $kerberos_conf= "/etc/krb5.conf" 
	$ad_user= "foreman"
	$royaume= upcase ($ad_domain)

#Packages pour Active Directory
	package { $pkg_lst:
		ensure=> installed,
	}

#Fichiers de configuration
	File {
		ensure=> present,
		owner=> root,
		group=> root,
		mode=> '0600',
		require=> Package[$pkg_lst],
	}
	file {$foreman_keytab:
		source=> 'puppet:///modules/netservices/foreman.keytab',
	} 
	file {$sssd_conf:
		content=> template('netservices/sssd.conf.erb'),
	}
	file {$kerberos_conf:
		content=> template('netservices/krb5.conf.erb'),
		mode=> '0644',
	}
	exec {'enable_sssd_mkhomedir':
		path=> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin",
		command=>"authconfig --update --enablesssd --enablesssdauth --enablemkhomedir",
		unless=> 'authconfig --test| grep mkhomedir| grep enabled',
		require=> [ File[$foreman_keytab,$sssd_conf,$kerberos_conf] ],
	}
	exec {'init_foreman':
		path=> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin",
		command=> "kinit -kt ${foreman_keytab} ${ad_user}",
		unless=> 'klist -ke',
		require=> [ File[$foreman_keytab,$sssd_conf,$kerberos_conf] ],
		notify=> Exec['ad_join'],
	}
	exec {'ad_join':
		path=> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin",
		command=> "adcli join --login-ccache ${royaume}",
		refreshonly=> true,
		require=> [ File[$foreman_keytab,$sssd_conf,$kerberos_conf] ],
	}
	service{'sssd':
		enable=> true,
		ensure=> running,
		require=> [ Exec['ad_join'] ],
	}
}
