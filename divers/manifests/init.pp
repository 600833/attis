class divers ( $stage = main )
inherits  divers::params
{

	schedule {'sch_once_daily':
		period=> daily,
		repeat=> 2,
	}
	file {'config_dir':
		ensure=> directory,
		path=> "/CONFIG",
		owner=> 0,
		group=> 0,
		mode=> '0755',
	}
	file {'facts_list':
		ensure=> present,
                path=> '/CONFIG/facts.list',
		content=> inline_template('<%=scope.to_yaml %>'),
		show_diff=> false,
                backup=> false,
		require=> File['config_dir'],
#		schedule=> 'sch_once_daily',
	}
#	notify{"facts_test":
#	message=> "$facts",
#	}
}
