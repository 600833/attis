#
# install mvn and jvm on client node
# mvn client binary is stored in git repository
#
class attis::install_maven ( $stage ='main',$install_user='',$install_group='',$nexus_repo_name)
inherits attis
{
 $param['git']['clones'].each |$rpo| {
#
#Overide hiera install user or group
#
  if $install_user == '' 
   { $install_user2=$rpo['install_user'] }
  else
   { $install_user2=$install_user }
  if $install_group == '' 
   { $install_group2=$rpo['install_group'] }
  else
   { $install_group2=$install_group }
  attis::git::clone {$rpo['name']:
   repo_name=> $rpo['name'],
   branch_name=> master,
   repo_path=> $rpo['git_path'],
   gitserver=> $param['git']['ssh']['gitserver'],
   install_dir=> $rpo['install_dir'],
   proto=> $param['git']['default_proto'],
   gitlogin=> $param['git']['http']['gitlogin'],
   gitpwd=> $param['git']['http']['gitpwd'],
   install_user=> $install_user2,
   install_group=> $install_group2,
   auto_update=> str2bool($rpo['auto_update']),
  }
  if ( $rpo['name'] == "maven" ) {
   file { "${rpo['install_dir']}/conf/settings.xml":
    ensure=> present,
    owner=> $install_user2,
    group=> $install_group2,
    mode=> '0644',
    content=> template("${module_name}/maven_settings.xml.erb"),
#
#exec in  attis::git::clone 'maven': ...
#
    require=> Exec['clone_maven'],
   }
  }
 }
#
#add JAVA_HOME and /bin to PATH
#
 file_line {'export_java_home':
   ensure=> present,
   path=> $param['maven']['profile'],
   line=> "export JAVA_HOME=${param['maven']['java_home']} #PUPPET_JAVA_HOME",
   match=> "#PUPPET_JAVA_HOME",
 }
#
#add JAVA environment variables in root profile
#
 file_line {'export_path':
   ensure=> present,
   path=> $param['maven']['profile'],
   line=> "export PATH=\$PATH:${param['maven']['maven_bin_path']} #PUPPET_EXPORT_PATH",
   match=> "#PUPPET_EXPORT_PATH",
 }
}
