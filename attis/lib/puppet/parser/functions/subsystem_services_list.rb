$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:subsystem_services_list, :type => :rvalue) do |args|
	tsys_name,srv_version,srv_name,oper=args[0],args[1],args[2],args[3]
        tobj=Faunus::Mavens.new(tsys_name,srv_version,srv_name)
	case oper
        when /^DOWNLOAD_LIST$/i then 
		lst=tobj.instance_variable_get "@client_cmd_list"
        	return lst
	when /^INSTALL_LIST$/i then
		lst=tobj.instance_variable_get "@deplist"
		return lst
        else
		raise %Q(oper code unknown #{oper} )
	end
      end
end
