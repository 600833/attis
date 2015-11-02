$LOAD_PATH<<File.dirname(__FILE__)
module Puppet::Parser::Functions
      newfunction(:eval2, :type => :rvalue) do |args|
	eval(args[0])
      end
end
