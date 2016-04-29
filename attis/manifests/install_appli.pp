class attis::install_appli( $stage= 'main')
inherits attis
{
	$conf_dir='/CONFIG'
	$java_home=$param['maven']['java_home']
	$mbin=$param['maven']['maven_bin_path']
	$exec_path="/usr/sbin:/usr/bin:/bin:${mbin}"
	$exec_env="JAVA_HOME=${java_home}"
        if defined('$subsystem_id') {
         $tsystem_name=$subsystem_id
        }
        if defined('$subsystem_binary_version') {
         $tsystem_version=$subsystem_binary_version
        }
        if defined('$subsystem_services_list') {
         $tsubsystem_name=$subsystem_services_list 
        }
        
#	$install_list=tsubsys_list($tsystem_name,$tsystem_version,$tsubsystem_name)
#	$x1=tsubsys_list($tsystem_name,$tsystem_version,$tsubsystem_name)
#	$install_list=$x1[0]
#	$pom_xml="${conf_dir}/${tsystem_name}_${tsystem_version}_${tsubsystem_name}_pom.xml"
#	$cctv_pom_xml="${conf_dir}/${tsystem_name}_${tsystem_version}_pom.xml"
#	$cmd_maven_get="${x1[1]}${pom_xml}"
#	$cmd_maven_get_cctv="${x1[2]}${cctv_pom_xml}"
        $full_maven_download_tag="${conf_dir}/full_maven_download_${tsystem_name}_${tsystem_version}.mvn.dld"
        $srv_list=subsystem_services_list($tsystem_name,$tsystem_version,$tsubsystem_name,'DOWNLOAD_LIST')
	$srv_list.each |$cmd| {
		exec {"${cmd['flag']}":
			path=> $exec_path,
			command=> "${cmd['cmd']}",
			logoutput=> true,
			environment=> $exec_env,
			creates=> "${cmd['flag']}",
			cwd=> $conf_dir,
			user=> 0,
			group=> 0,
		}
		file {"${cmd['flag']}":
			require=> Exec["${cmd['flag']}"],
			ensure=> present,
			owner=> 0,
			group=> 0,
			mode=> '0644',
			notify=> File[$full_maven_download_tag],
		}
	}
        file{$full_maven_download_tag:
                ensure=> present,
                owner=> root,
                group=> root,
                mode=> '0644',
        }
        $install_list=subsystem_services_list($tsystem_name,$tsystem_version,$tsubsystem_name,'INSTALL_lIST')
#	notify { "${install_list}":}
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
		exec {$install_dir:
			path=> $exec_path,
                        command=> "mkdir -p ${install_dir};chown ${install_user}:${install_group} ${install_dir}",
			logoutput=> true,
			require=> File[$full_maven_download_tag],
			creates=> $install_dir
		}
                if ( $fmt == 'rpm' ) {
                  $install_user2 = 'root'
                  $install_group2 = 'root' 
                }
                else {
                  $install_user2 = $install_user
                  $install_group2 = $install_group
                }
                exec {$install_cmd:
                        path=> $exec_path,
                        environment=> $exec_env,
                        command=> $install_cmd,
                        logoutput=> true,
                        creates=> $installation_tag,
                        cwd=> $install_dir,
                        require=> Exec[$install_dir],
#                       notify=> File[$install_link],
			user=> $install_user2,
			group=> $install_group2,
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
