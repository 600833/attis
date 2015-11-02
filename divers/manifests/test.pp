class divers::test
{
	file {'/tmp/template.test':
		ensure=> present,
		content=>template('divers/template.test.erb'),
	}
	$fwservices2=hiera("fwservices2")
	notice ($fwservices2)
}
