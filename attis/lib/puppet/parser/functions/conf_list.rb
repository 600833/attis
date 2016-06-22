#
#get a list of artifacts conf for a given subsystem and version
#
$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:conf_list, :type => :rvalue) do |args|
	conf_name,conf_version,puppet_dir,puppet_env=args[0],args[1],args[2],args[3]
        conf_obj=Faunus::Maven.load(conf_name,conf_version)
	conf_obj.conf_dep_list(puppet_dir,puppet_env)
        conf_obj.deplist
      end
end
