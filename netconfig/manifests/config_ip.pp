class netconfig::config_ip ( $stage='main') {
 $if_script_dir='/etc/sysconfig/network-scripts'
 $interface_attrs=foreman_netconfig('list')
 notify{"interface_attrs": 
  message=> "${interface_attrs}",
 }
 $dbg=""
 $interface_attrs.each | $this_inter | {
  if $this_inter['type'] == "Bond" and $this_inter['critic']=="no" {
   $if_script="ifcfg-${this_inter['identifier']}"
   file {"$if_script_dir/${dbg}${if_script}":
    ensure=>present,
    owner=>0,
    group=>0,
    mode=> '644',
    content=>template("$module_name/if_script_bond_master.erb"),
    notify=> Exec['ShutDownNetworkManager'],
   }
   if empty(grep($this_inter['missing'],"(no_subnet|no_ip)")) {
    $iproute2_rule_script="rule-${this_inter['identifier']}"
    $iproute2_route_script="route-${this_inter['identifier']}"
    $iproute2_route_table="table_${this_inter['identifier']}"
    $iproute2_route_table_index="${$this_inter['rt_index']+5100}"
    sauver('rt_table',"${iproute2_route_table_index} ${iproute2_route_table}")
    file {"$if_script_dir/${dbg}${iproute2_rule_script}":
     ensure=> present,
     owner=> 0,
     group=> 0,
     mode=> '644',
     content=> template("$module_name/iproute2_rule_script.erb"),
     notify=> Exec['ShutDownNetworkManager'],
    }
    file {"$if_script_dir/${dbg}${iproute2_route_script}":
     ensure=> present,
     owner=> 0,
     group=> 0,
     mode=> '644',
     content=> template("$module_name/iproute2_route_script.erb"),
     notify=> Exec['ShutDownNetworkManager'],
    }
   }
  }
  elsif $this_inter['classe'] == 'slave' {
    $if_script="ifcfg-${this_inter['identifier']}"
    file {"$if_script_dir/${dbg}${if_script}":
     ensure=>present,
     owner=>0,
     group=>0,
     mode=> '644',
     content=>template("$module_name/if_script_bond_slave.erb"),
     notify=> Exec['ShutDownNetworkManager'],
    }
  }
  elsif ( $this_inter['classe'] == 'subinterface' or $this_inter['classe'] == 'standard' or $this_inter['classe'] == 'vlan') and $this_inter['critic'] == 'no' {
   $if_script="ifcfg-${this_inter['identifier']}"
   file {"$if_script_dir/${dbg}${if_script}":
    ensure=>present,
    owner=>0,
    group=>0,
    mode=> '644',
    content=>template("$module_name/if_script_commun.erb"),
    notify=> Exec['ShutDownNetworkManager'],
   }
   if empty(grep($this_inter['missing'],"(no_subnet|no_ip)")) {
    $iproute2_rule_script="rule-${this_inter['identifier']}"
    $iproute2_route_script="route-${this_inter['identifier']}"
    $iproute2_route_table="table_${this_inter['identifier']}"
    $iproute2_route_table_index="${$this_inter['rt_index']+5100}"
    sauver('rt_table',"${iproute2_route_table_index} ${iproute2_route_table}")
    file {"$if_script_dir/${dbg}${iproute2_rule_script}":
     ensure=> present,
     owner=> 0,
     group=> 0,
     mode=> '644',
     content=> template("$module_name/iproute2_rule_script.erb"),
     notify=> Exec['ShutDownNetworkManager'],
    }
    file {"$if_script_dir/${dbg}${iproute2_route_script}":
     ensure=> present,
     owner=> 0,
     group=> 0,
     mode=> '644',
     content=> template("$module_name/iproute2_route_script.erb"),
     notify=> Exec['ShutDownNetworkManager'],
    }
   }
  }
 }
#
#update iproute2 rt_tables
#
 $rt_table_plus=restaurer('rt_table')
 file {"/etc/iproute2/${dbg}rt_tables":
  ensure=> present,
  owner=> 0,
  group=> 0,
  mode=> '644',
  content=> template("$module_name/rt_tables.erb"),
  notify=> Exec['ShutDownNetworkManager'],
 }
#
#restart service
#
 exec {'ShutDownNetworkManager':
  path=> "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
  logoutput=> true,
  refreshonly=> true,
  command=> "systemctl stop NetworkManager;systemctl status NetworkManager;echo ''",
  notify=> Service['network'],
 }
 if  defined(Service['firewalld.service']) {
  service {'network':
   enable => true,
   ensure=>running,
   notify=>Service['firewalld.service','NetworkManager'],
   before=>Service['NetworkManager'],
  }
 }
 else {
  service {'network':
   enable => true,
   ensure=>running,
   notify=>Service['NetworkManager'],
   before=>Service['NetworkManager'],
  }
 }
 unless defined(Service['NetworkManager']) {
  service {'NetworkManager':
   enable => true,
   ensure=> running,
  }
 }
}
