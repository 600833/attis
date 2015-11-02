class essai
(
	$serveur = $essai::params::serveur,
	$texte = $essai::params::texte,
	$stage = main
)
inherits  essai::params
{

	file {'essai_data':
		ensure=> present,
                path => '/tmp/essai.data',
                content=> "transformer tvs\n", 
        }
        file {'essai_conf':
                ensure => present,
                path => '/tmp/essai_conf.puppet',
                content=> $texte,
                tag=> ['fic2'],
                noop=> false,
                audit=> all,
        }
}
