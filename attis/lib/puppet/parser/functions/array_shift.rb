module Puppet::Parser::Functions
      newfunction(:array_shift, :type => :rvalue) do |args|
	vec,nb=args[0],args[1]
        vec.shift nb
        return vec
      end
end
