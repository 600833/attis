$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:deployer_list, :type => :rvalue) do |args|
	deployer_name,deployer_version,puppet_dir,puppet_env=args[0],args[1],args[2],args[3]
        deployer_obj=Faunus::Maven.load(deployer_name,deployer_version)
	deployer_obj.deployer_dep_list(puppet_dir,puppet_env)
        deployer_obj.deplist
      end
end
