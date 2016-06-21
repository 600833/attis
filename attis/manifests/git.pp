#
#define type attis::git::clone, this type clone a git repository 
# and set owner($install_user) and group($install_group) of the cloned repository
#
define attis::git::clone 
(
 $repo_name,     #remote git repository name
 $branch_name,   #local git branch name
 $repo_path,     #URL path of remote git repository
 $install_dir,   #local directory path
 $gitserver='',  #git server's dns name
 $proto='http',  #git clone protocole ssh or http
 $gitlogin='',   #git server account
 $gitpwd='',     #git server account's password
 $install_user='',   # local owner of local repository
 $install_group='',  # local group owner of local repository 
 $auto_update=true,  # auto merge change from remote to local on each puppet run
)
{
#
# sucessfull cloning tag in /CONFIG
#
 $clone_tag="/CONFIG/gitrepo_${repo_name}${regsubst($repo_path,'/','.','G')}_to_${regsubst($install_dir,'/','.','G')}.tag"
#
# input parameter checking
#
 if empty($install_dir) or empty($repo_name) or empty($branch_name) or empty($repo_path) or empty($gitserver) or empty($gitlogin) or empty($gitpwd) { fail( "empty parameter") }
 if $install_dir !~ '^/.+/.*[^/]$' { fail('install_dir must be format /xxx/yyy') }
#
#run cloning
#
 case $proto {
#
# cloning over http
#
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
#
# cloning over ssh
#
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
#
#  other protocole is not yet managed
#
   default: {
    fail("git cloning $repo_name to $install_dir: protocole unknown")
   }
 }
#
# run git pull
#
 if ($auto_update == true) {
   exec {"clone_update_${repo_name}":
   path=>'/bin',
   cwd=> $install_dir,
   command=> "git pull",
   notify=> Exec["clone_${repo_name}_chown"],
   logoutput=> true,
   onlyif=> ["test -f ${clone_tag}","git fetch --dry-run 2>&1| grep -i master"],
  }
 }
#
# set sucessful tag
#
 file {$clone_tag:
  content=> "${cmd}\n",
  require=> Exec["clone_${repo_name}"],
  ensure=> present,
  mode=>'0600',
  owner=> 0,
  group=> 0,
 }
#
# change new local repository owner and group owner
#
 if ! ( empty($install_user) or empty($install_group)) {
  exec {"clone_${repo_name}_chown" :
   path=> "/bin",
   command=> "chown -R ${install_user}:${install_group} ${install_dir}",
   refreshonly=> true,
   logoutput=> true,
  }
 }
}
#
#setup ssh client environment to allow git over ssh
#
class attis::git::init_ssh ( $stage = 'main' ) 
inherits attis
{
 File {
  ensure=> present,
  owner=> 0,
  group=> 0,
  mode=> $param['git']['ssh']['file_mode'],
 }
#
#install rpm package for ssh client
#
 package{$param['git']['dep_packages']:
  ensure=> installed,
 }
#
#create ssh client config directory
#
 file {$param['git']['ssh']['config_dir']:
  ensure=> directory,
  mode=> $param['git']['ssh']['config_dir_mode'],
  require=> Package[$package_list],
 } 
#
#create rsa key
#
 file {$param['git']['ssh']['rsa_keyfile']:
  path=> "${param['git']['ssh']['config_dir']}/${param['git']['ssh']['rsa_keyfile']}",
  content=> template ("${module_name}/${param['git']['ssh']['rsa_keyfile']}.erb"),
  require=> Package[$package_list],
 }
#
#create ssh client config file
#
 file {'ssh_client_conf':
  path=> "${param['git']['ssh']['config_dir']}/config",
  content=> template("${module_name}/ssh_client_conf.erb"),
  require=> Package[$package_list],
 }
}
