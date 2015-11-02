class attis::install_deployer( $stage= 'main',$deployer_list,$puppet_env)
inherits attis
{
	$conf_dir='/CONFIG'
	$java_home=$param['maven']['java_home']
	$mbin=$param['maven']['maven_bin_path']
	$exec_path="/usr/sbin:/usr/bin:/bin:${mbin}"
	$exec_env="JAVA_HOME=${java_home}"
	$puppet_dir='/app/puppet'
	$deployer1=split($deployer_list,'[\,\;]')
	$inlist1 = $deployer1.reduce([]) |$somme,$dpl| {
		$a1=split($dpl,':')
		$deployer_name=strip($a1[0])
		$deployer_version=strip($a1[1])
		$inlist=deployer_list($deployer_name,$deployer_version,$puppet_dir,$puppet_env)
		concat($somme,$inlist)
         }
	$install_list = array_unique($inlist1,5)
	$install_list.each |$tsub| {
		$groupid=$tsub[0]
               	$artifact=$tsub[1]
		$fmt=$tsub[2]
               	$vers=$tsub[3]
               	$archive=$tsub[5]
		$install_dir=$tsub[6]
		$install_cmd=$tsub[7]
		$module_dir=$tsub[8]
		$link_create_cmd=$tsub[9]
		$installation_tag="${conf_dir}/${groupid}_${artifact}_${vers}.installed"
		$exec_link_create="exec_link_${groupid}_${artifact}_${vers}"
		notice($tsub)
		exec {$install_dir:
			path=> $exec_path,
                       	command=> "mkdir -p ${install_dir}",
			logoutput=> true,
			creates=> $install_dir
		}
               	exec {$install_cmd:
                       	path=> $exec_path,
                       	environment=> $exec_env,
                       	command=> $install_cmd,
                       	logoutput=> true,
                       	cwd=> $install_dir,
                       	require=> Exec[$install_dir],
                       	creates=> $installation_tag,
			notify=> Exec[$exec_link_create],
               	}
		file {$installation_tag:
			ensure=> present,
			owner=> root,
			group=> root,
			mode=> '0644',
			require=> Exec[$install_cmd],
		}
#        	file{$install_link:
#              		ensure=> link,
#              		target=> $install_link_target,
#              		owner=> root,
#              		group=> root,
#              		mode=> '0644',
#             		subscribe =>Exec[$install_cmd]
#              	}
		exec {$exec_link_create:
			path=> $exec_path,
			environment=> $exec_env,
			cwd=> $module_dir,
			command=> $link_create_cmd,
			refreshonly=> true,
			logoutput=> true,
		}
        }
}
