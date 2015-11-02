class netconfig::ip ( $stage = main )
{
	$foreman_defined_networks = $foreman_interfaces.count
	case $network_model {
        "virtual_double" : { 		
        notice('run netconfig::ip')
        if $foreman_defined_networks ==  2
        {
            notify { "virtual double network adapters and Nb of network defined: ${foreman_defined_networks}" :}
			$x1 = $pcidevices.filter |$s| { $s["device"].downcase  =~ /ethernet/ }
			$mac2dv = $x1.map |$s| { {'macaddress'=> $s['macaddress'],'dvname'=> $s['dvname']} }
            $defined_mac_list = $foreman_interfaces.map |$s| { $s['mac'] }
            $found_mac_list = $mac2dv.map |$s| { $s['macaddress'] }
            $df1 = concat (difference ( $found_mac_list, $defined_mac_list ),difference ($defined_mac_list,$found_mac_list ))
            if $df1 == []
            {
                notify {"defined macaddress and real macaddress are the same: ${found_mac_list}":}
            }
            else
            {
                fail ("defined macaddress and real macaddress differ: ${df1}")
            }
	    $f1= foreman_interfaces2 ( $foreman_interfaces,$mac2dv)
            $f1.each |$cle| {
                if $cle != 'lo'
                {
		    $dvname = $cle["dvname"]
                    file { "ifcfg-${dvname}":
                    ensure=> present,
                    path=> "/etc/sysconfig/network-scripts/ifcfg-${dvname}",
#                    path=> "/etc/sysconfig/network-scripts/ifcfg-${dvname}.out",
                    content=> template('netconfig/ifcfg.erb'),
		    notify=> Exec['ShutDownNetworkManager'],
		    }
		    if $cle["provision"] {
                    	file { "route-${dvname}":
                    	ensure=> present,
#                    	path=> "/etc/sysconfig/network-scripts/route-${dvname}.out",
                    	path=> "/etc/sysconfig/network-scripts/route-${dvname}",
                    	content=> template('netconfig/route.erb'),
			notify=> Exec['ShutDownNetworkManager'],
			}
		    }
           	}     
             }
	}
	else
	{
			fail {"virtual double network adapters and Nb of network defined: ${foreman_defined_networks}" :}
	}
	}
	}

        exec {'ShutDownNetworkManager':
		path=> "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin",
		logoutput=> true,
                refreshonly=> true,
                command=> "systemctl stop NetworkManager;systemctl status NetworkManager;echo ''",
		notify=> Service['network'],
         }
	   
	service {'network':
		enable => true,
		ensure=>running,
		notify=>Service['firewalld.service','NetworkManager'],
		before=>Service['NetworkManager'],
	}

	service {'NetworkManager':
		enable => true,
		ensure=> running,
	}
}
