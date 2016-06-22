#
#full list of artifacts for a given subsyatem
#
$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:tsys_list, :type => :rvalue) do |args|
	tsys_name,tsys_version=args[0],args[1]
        tsys_obj=Faunus::Maven.load(tsys_name,tsys_version)
	tsys_obj.bin_dep_list()
        tsys_obj.deplist
      end
end
