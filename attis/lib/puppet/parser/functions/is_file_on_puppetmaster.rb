#
#check existance of a file on puppet master
#
module Puppet::Parser::Functions
      newfunction(:is_file_on_puppetmaster, :type => :rvalue) do |args|
	File.exists?(args[0])
      end
end
