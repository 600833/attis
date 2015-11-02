define attis::git::clone 
(
	$repo_name,
	$branch_name,
	$repo_path,
	$install_dir,
	$gitserver='',
	$proto='http',
        $gitlogin='',
        $gitpwd='',
	$install_user='',
	$install_group='',
	$auto_update=true,
)
{
	$clone_tag="/CONFIG/gitrepo_${repo_name}${regsubst($repo_path,'/','.','G')}_to_${regsubst($install_dir,'/','.','G')}.tag"
	if empty($install_dir) or empty($repo_name) or empty($branch_name) or empty($repo_path) or empty($gitserver) or empty($gitlogin) or empty($gitpwd) { fail( "empty parameter") }
	if $install_dir !~ '^/.+/.*[^/]$' { fail('install_dir must be format /xxx/yyy') }
	case $proto {
	'http': {
		$cmd="/bin/rm -rf ${install_dir};git clone -o ${repo_name} -b ${branch_name} http://${gitlogin}:${gitpwd}@${gitserver}${repo_path} ${install_dir}"
		exec {"clone_${repo_name}":
			path=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
			creates=> "$clone_tag",
			command=> $cmd,
			logoutput=> true,
			notify=> Exec["clone_${repo_name}_chown"],
		}
	}
	'ssh': {
		$docroot=$attis::git::init_ssh::param['git']['ssh']['docroot']
		$cmd="/bin/rm -rf ${install_dir};git clone -o ${repo_name} -b ${branch_name} ssh://gitserver${docroot}${repo_path} ${install_dir}"
		exec {"clone_${repo_name}":
			path=> '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
			creates=> $clone_tag,
			command=> $cmd,
			logoutput=> true,
			require=> Class['attis::git::init_ssh'],
			notify=> Exec["clone_${repo_name}_chown"],
		}
	}
	default: {
		fail("git cloning $repo_name to $install_dir: protocole unknown")
	}
	}
	if ($auto_update == true) {
	exec {"clone_update_${repo_name}":
		path=>'/bin',
		cwd=> $install_dir,
		command=> "git pull",
		notify=> Exec["clone_${repo_name}_chown"],
		logoutput=> true,
		onlyif=> ["test -f ${clone_tag}","git fetch --dry-run 2>&1| grep -i master"],
	}}
	file {$clone_tag:
		content=> "${cmd}\n",
		require=> Exec["clone_${repo_name}"],
		ensure=> present,
		mode=>'0600',
		owner=> 0,
		group=> 0,
	}
	if ! ( empty($install_user) or empty($install_group)) {
	exec {"clone_${repo_name}_chown" :
		path=> "/bin",
		command=> "chown -R ${install_user}:${install_group} ${install_dir}",
		refreshonly=> true,
		logoutput=> true,
	}}
	
}
class attis::git::init_ssh ( $stage = 'main' ) 
inherits attis
{
	File {
		ensure=> present,
		owner=> 0,
		group=> 0,
		mode=> $param['git']['ssh']['file_mode'],
	}
	package{$param['git']['dep_packages']:
		ensure=> installed,
	}
	file {$param['git']['ssh']['config_dir']:
		ensure=> directory,
		mode=> $param['git']['ssh']['config_dir_mode'],
		require=> Package[$package_list],
	} 
	file {$param['git']['ssh']['rsa_keyfile']:
		path=> "${param['git']['ssh']['config_dir']}/${param['git']['ssh']['rsa_keyfile']}",
		content=> template ("${module_name}/${param['git']['ssh']['rsa_keyfile']}.erb"),
		require=> Package[$package_list],
	}
	file {'ssh_client_conf':
		path=> "${param['git']['ssh']['config_dir']}/config",
		content=> template("${module_name}/ssh_client_conf.erb"),
		require=> Package[$package_list],
	}
}
