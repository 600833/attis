class netservices::snmp( $stage='main',$etat_service='running',$etat_package='installed')
{
	$package_name='net-snmp'
	$snmptrap='snmptrapd.conf'
        $snmpd='snmpd.conf'
	$snmp_service='snmpd.service'
	$snmptrap_service='snmptrapd.service'
	case $etat_package {
	'absent' : {
		$activite=false
		$etat_service2='stopped'
		$conf_file='absent'
	}
	default : {
		$etat_service2=$etat_service
		case $etat_service {
		'running': { $activite=true }
		'stopped': { $activite=false }
		}
		$conf_file='present'
	}
	}
	package {$package_name:
		ensure=>$etat_package,
	}
	File {  ensure=> $conf_file,
		owner=> root,
		group=> root,
		mode=> '0600',
	}
	file {"$snmpd":
		path=> "/etc/snmp/${snmpd}",
		content=> template("${module_name}/snmp/${snmpd}.erb"),
	}
	file {"$snmptrap":
		path=> "/etc/snmp/${snmptrap}",
		content=> template("${module_name}/snmp/${snmptrap}.erb")
	}
	service {[$snmp_service,$snmptrap_service]:
		ensure=> $etat_service2,
		enable=> $activite,
	}
	case $etat_package {
		'absent' : {
			Service[$snmp_service,$snmptrap_service] ->  File[$snmpd,$snmptrap] -> Package[$package_name]
		}
		default : {
			Package[$package_name] ~> File[$snmpd,$snmptrap]
			File[$snmpd] ~> Service[$snmp_service]
			File[$snmptrap] ~> Service[$snmptrap_service]
		}
	}
}
