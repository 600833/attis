$LOAD_PATH<<File.dirname(__FILE__)
module Puppet::Parser::Functions
 newfunction(:restaurer, :type=> :rvalue) do |args|
  raise 'function sauver must have 2 arguments' if args.count <1
  unless defined? @sauvee
   nil
  else
   @sauvee[args[0]]
  end
 end
end
