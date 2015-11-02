class essai::params {
	$texte = 'message texte défini dans classe params'
	case $::osfamily {
	'RedHat': {
		$serveur = 'serveur_centos_7.1'
	}
	Default: {
		$serveur = 'unix os'
	}
	}
}
