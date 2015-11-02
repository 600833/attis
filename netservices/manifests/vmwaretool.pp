class netservices::vmwaretool( $stage='main',$etat_service='running',$etat_package='installed')
{
	$package_name='open-vm-tools'
	$vmtoolsd_service='vmtoolsd.service'
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
	service {$vmtoolsd_service:
		ensure=> $etat_service2,
		enable=> $activite,
	}
	case $etat_package {
		'absent' : {
			Service[$vmtoolsd_service] -> Package[$package_name]
		}
		default : {
			Package[$package_name] ~> Service[$vmtoolsd_service]
		}
	}
}
