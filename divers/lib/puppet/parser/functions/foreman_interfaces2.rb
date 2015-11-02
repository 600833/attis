$LOAD_PATH<<File.dirname(__FILE__)
require 'finter2.rb'
module Puppet::Parser::Functions
      newfunction(:foreman_interfaces2, :type => :rvalue) do |args|
	finter2(args[0],args[1])
      end
end
