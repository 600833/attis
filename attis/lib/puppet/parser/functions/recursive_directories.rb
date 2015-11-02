$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:recursive_directories, :type => :rvalue) do |args|
	Object.new().extend(Faunus).send 'recursive_directories',args[0],args[1],args[2]
      end
end
