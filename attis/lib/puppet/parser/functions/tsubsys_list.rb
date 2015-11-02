$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:tsubsys_list, :type => :rvalue) do |args|
	tsys_name,tsys_version,tsubsys_name=args[0],args[1],args[2]
        tsys_obj=Faunus::Maven.new(tsys_name,tsys_version)
	tsys_obj.bin_dep_list()
	ligne,sub_ver=tsys_obj.get_version(tsubsys_name)
        tsub_obj=Faunus::Maven.new(tsys_name,sub_ver,artifact: tsubsys_name)
        tsub_obj.bin_dep_list(myline: ligne)
        return tsub_obj.deplist,tsub_obj.get_cmd_p1,tsys_obj.get_cmd_p1
      end
end
