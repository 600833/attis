class attis::install_appli( $stage= 'main')
inherits attis
{
	$conf_dir='/CONFIG'
	$java_home=$param['maven']['java_home']
	$mbin=$param['maven']['maven_bin_path']
	$exec_path="/usr/sbin:/usr/bin:/bin:${mbin}"
	$exec_env="JAVA_HOME=${java_home}"
#	$install_list=tsubsys_list($tsystem_name,$tsystem_version,$tsubsystem_name)
	$x1=tsubsys_list($tsystem_name,$tsystem_version,$tsubsystem_name)
	$install_list=$x1[0]
	$pom_xml="${conf_dir}/${tsystem_name}_${tsystem_version}_${tsubsystem_name}_pom.xml"
	$cctv_pom_xml="${conf_dir}/${tsystem_name}_${tsystem_version}_pom.xml"
	$cmd_maven_get="${x1[1]}${pom_xml}"
	$cmd_maven_get_cctv="${x1[2]}${cctv_pom_xml}"
        $full_maven_download_tag="${conf_dir}/full_maven_download_${tsystem_name}_${tsystem_version}_${tsubsystem_name}.tag"
	exec {$cmd_maven_get_cctv:
		path=> $exec_path,
		environment=> $exec_env,
                command=> $cmd_maven_get_cctv,
		logoutput=> true,
		creates=> $full_maven_download_tag,
	}
	exec {$cmd_maven_get:
		path=> $exec_path,
		environment=> $exec_env,
                command=> $cmd_maven_get,
		logoutput=> true,
		creates=> $full_maven_download_tag,
		require=>Exec[$cmd_maven_get_cctv]
	}
	file{$full_maven_download_tag:
		ensure=> present,
		owner=> root,
		group=> root,
		mode=> '0644',
		require=> Exec[$cmd_maven_get]
	}
        $install_list.each |$tsub| {
		$groupid=$tsub[0]
                $artifact=$tsub[1]
		$fmt=$tsub[2]
                $vers=$tsub[3]
                $archive=$tsub[5]
		$install_dir=$tsub[6]
		$install_cmd=$tsub[7]
		$install_link=$tsub[8]
		$install_link_target=$tsub[9]
		$installation_tag="${conf_dir}/${groupid}_${artifact}_${vers}.installed"
#		file {$install_dir:
#			ensure=> directory,
#			owner=> root,
#			group=> root,
#			mode=> '0755',
#		}
		exec {$install_dir:
			path=> $exec_path,
                        command=> "mkdir -p ${install_dir}",
			logoutput=> true,
			require=> File[$full_maven_download_tag],
			creates=> $install_dir
		}
                exec {$install_cmd:
                        path=> $exec_path,
                        environment=> $exec_env,
                        command=> $install_cmd,
                        logoutput=> true,
                        creates=> $installation_tag,
                        cwd=> $install_dir,
                        require=> Exec[$install_dir],
#                       notify=> File[$install_link]
                }
		file {$installation_tag:
			ensure=> present,
			owner=> root,
			group=> root,
			mode=> '0644',
			require=> Exec[$install_cmd],
		}
               file{$install_link:
                     ensure=> link,
                     target=> $install_link_target,
                     owner=> root,
                     group=> root,
                     mode=> '0644',
        	     subscribe =>Exec[$install_cmd]
               }
        }
}
