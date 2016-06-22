#
#itemize a string to hash by a separator
#
$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
      newfunction(:itemize2array, :type => :rvalue) do |args|
	vec=args[0]
        pC=Class.new(Faunus::Mavens)
        pC.class_eval do
         def initialize
         end
        end
        p1=pC.new
        return p1.itemize(vec)
      end
end
