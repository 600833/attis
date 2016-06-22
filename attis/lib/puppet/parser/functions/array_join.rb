#
#transform a array on string with a separator as second argument
#
$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:array_join, :type => :rvalue) do |args|
	vec,sep=args[0],args[1]
        return  vec.join(sep)
      end
end
