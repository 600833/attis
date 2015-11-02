class netservices::syslog ( $stage = main )
{
	$journald_conf="/etc/systemd/journald.conf"
	$rsyslog_conf="/etc/rsyslog.conf"
	$rsyslog_conf_dir="/etc/rsyslog.d"
	$service_rsyslog="rsyslog.service"
	package {'rsyslog':
		ensure=> installed,
	}
	file {$rsyslog_conf:
		ensure=> present,
		owner=> root,
		group=> root,
		mode=> '0644',
		content=> template("netservices/syslog/rsyslog.conf.erb"),
		require=> Package['rsyslog'],
		notify=> Service[$service_rsyslog]
	}
	file {$rsyslog_conf_dir:
		ensure=> directory,
		owner=> root,
		group=> root,
		mode=> '0755',
		purge=> true,
		recurse=> true,
		require=> Package['rsyslog'],
		source=> "puppet:///modules/netservices/syslog",
		notify=> Service[$service_rsyslog]
	}
	service {$service_rsyslog:
  		ensure=> running,
  		enable=> true,
	}
	file {$journald_conf:
                ensure=> present,
                owner=> root,
                group=> root,
                mode=> '0755',
		content=> template("netservices/syslog/journald.conf.erb"),
	}
}
