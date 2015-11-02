$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:array_unique, :type => :rvalue) do |args|
	vec,pos=args[0],args[1]
	Object.new().extend(Faunus).send 'uniquebyentry',vec,pos
      end
end
