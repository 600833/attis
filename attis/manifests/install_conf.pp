class attis::install_conf( $stage= 'main',$conf_list,$puppet_env)
inherits attis
{
	$tag_dir='/CONFIG'
	$java_home=$param['maven']['java_home']
	$mbin=$param['maven']['maven_bin_path']
	$exec_path="/usr/sbin:/usr/bin:/bin:${mbin}"
	$exec_env="JAVA_HOME=${java_home}"
	$puppet_dir='/app/puppet'
	$conf1=split($conf_list,'[\,\;]')
	$conf1.each |$dpl| {
		$a1=split($dpl,':')
		$conf_name=$a1[0]
		$conf_version=$a1[1]
		$install_list=conf_list($conf_name,$conf_version,$puppet_dir,$puppet_env)
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
			$hiera_link=$tsub[10]
			$hiera_link_target=$tsub[11]
			$installation_tag="${tag_dir}/${groupid}_${artifact}_${vers}.installed"
			$install_dir_list=recursive_directories($install_dir,4,false)
			$install_dir_list.each |$dr| {
				unless defined(File[$dr]) {
					file {$dr:
						ensure=> directory,
						owner=> puppet,
						group=> puppet,
					}
                        	}
			}
                	exec {$install_cmd:
                        	path=> $exec_path,
                        	environment=> $exec_env,
                        	command=> $install_cmd,
                        	logoutput=> true,
                        	cwd=> $install_dir,
                        	require=> File[$install_dir],
                        	creates=> $installation_tag,
				user=> puppet,
				group=> puppet,
                	}
			file {$installation_tag:
				ensure=> present,
				owner=> root,
				group=> root,
				mode=> '0644',
				require=> Exec[$install_cmd],
			}
			unless  $artifact == 'nodes'  or $artifact == 'common'
			{
				$ik2=recursive_directories($install_link,1,false)
				file {$ik2[count($ik2)-2]:
					ensure=> directory,
				}
               			file {$install_link:
                     			ensure=> link,
                     			target=> $install_link_target,
                     			owner=> root,
                     			group=> root,
                     			mode=> '0644',
        	     			subscribe =>Exec[$install_cmd]
               			}
	  		}
			case $artifact {
			'type-nodes': { 
				$ik3=recursive_directories($hiera_link,4,false)
				$ik3.each |$ik37| {
				unless defined(File[$ik37]) {
				file {$ik37:
					ensure=> directory,
					owner=> puppet,
					group=> puppet,
			     	}}}
				notify{"hiera_link : $hiera_link":}
			}
			default: {
				$ik3=recursive_directories($hiera_link,4,true)
				$ik3.each |$ik37| {
				unless defined(File[$ik37]) {
				file {$ik37:
					ensure=> directory,
					owner=> puppet,
					group=> puppet,
			     	}}}
				file {$hiera_link:
					ensure=> link,
					target=> $hiera_link_target,
				}
#				notify{"hiera_link : $hiera_link":}
			}}
        	}
	}
}
