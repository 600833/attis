module Puppet::Parser::Functions
      newfunction(:is_file_on_puppetmaster, :type => :rvalue) do |args|
	File.exists?(args[0])
      end
end
