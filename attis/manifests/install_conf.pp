#
#installation a specific configuration. this class should be run after deployer
#
class attis::install_conf( $stage= 'main',$conf_list,$puppet_env)
inherits attis
{
#
#set initial parameters
#
 $tag_dir=$param['config_dir']
 $java_home=$param['maven']['java_home']
 $mbin=$param['maven']['maven_bin_path']
 $exec_path="/usr/sbin:/usr/bin:/bin:${mbin}"
 $exec_env="JAVA_HOME=${java_home}"
 $puppet_dir=$param['puppet_dir']
 $conf1=split($conf_list,'[\,\;]')
#
# run this class only if mvn has been installed on puppet master
#
 if is_file_on_puppetmaster($mbin) == true {
#
#iterate over conf list, multiple subsystem and multiple conf version
#
  $conf1.each |$dpl| {
   $a1=split($dpl,':')
   $conf_name=strip($a1[0])
   $conf_version=strip($a1[1])
#
# get list artifacts from nexus for a given conf and  version
#
   $install_list=conf_list($conf_name,$conf_version,$puppet_dir,$puppet_env)
#
# install each artifact conf
#
   $install_list.each |$tsub| {
#
# set conf configuration parameters
#
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
    $install_dir_list=recursive_directories($install_dir,2,false)
#
# create recursively installation directory
#
    $install_dir_list.each |$dr| {
     unless defined(File[$dr]) {
      file {$dr:
       ensure=> directory,
       owner=> puppet,
       group=> puppet,
      }
     }
    }
#
# install conf
#
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
#
# set conf installation flag if successful
#
    file {$installation_tag:
     ensure=> present,
     owner=> root,
     group=> root,
     mode=> '0644',
     require=> Exec[$install_cmd],
    }
#
# set  symbolic link
#
    unless  $artifact == 'nodes'  or $artifact == 'common'
    {
#
# if not nodes or common artifacts
#
      $nc_sub_tree_lst=recursive_directories($install_link,1,false)
#
# create installation directory tree
#
      unless defined(File[$nc_sub_tree_lst[count($nc_sub_tree_lst)-2]]) {
       file {$nc_sub_tree_lst[count($nc_sub_tree_lst)-2]:
        ensure=> directory,
       }
      }
#
# create symbolic link
#
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
#
# if node conf, create directory tree
#
     'type-nodes': { 
      $lst_hiera_folder_tree=recursive_directories($hiera_link,4,false)
      $lst_hiera_folder_tree.each |$iv_hiera_tree| {
       unless defined(File[$iv_hiera_tree]) {
        file {$iv_hiera_tree:
         ensure=> directory,
         owner=> puppet,
         group=> puppet,
        }
       }
      }
      notify{"hiera_link : $hiera_link":}
     }
#
# for other conf 
#
     default: {
      $lst_hiera_folder_tree=recursive_directories($hiera_link,4,true)
       $lst_hiera_folder_tree.each |$iv_hiera_tree| {
        unless defined(File[$iv_hiera_tree]) {
         file {$iv_hiera_tree:
          ensure=> directory,
	  owner=> puppet,
          group=> puppet,
	 }
        }
       }
#
# create hiera symbolic link
#
       file {$hiera_link:
        ensure=> link,
        target=> $hiera_link_target,
       }
#      notify{"hiera_link : $hiera_link":}
      }
     }
    }
  }
 }
}
