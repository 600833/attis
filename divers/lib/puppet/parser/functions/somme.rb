module Puppet::Parser::Functions
      newfunction(:somme, :type => :rvalue) do |args|
		puts "xxxxx"
		args[0] + args[1]
      end
end

