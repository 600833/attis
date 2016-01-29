$LOAD_PATH<<File.dirname(__FILE__)
module Puppet::Parser::Functions
 newfunction(:sauver) do |args|
  raise 'function sauver must have 2 arguments' if args.count <2
  @sauvee=Hash.new() unless defined? @sauvee
  if @sauvee[args[0]].nil?
   @sauvee[args[0]]=args[1]
  elsif @sauvee[args[0]].is_a? Array
    @sauvee[args[0]].unshift(args[1])
  elsif args[2].nil? == false and args[2].downcase == "add"
    @sauvee[args[0]]=@sauvee[args[0]] + args[1]
  else
    @sauvee[args[0]]=[@sauvee[args[0]],args[1]] 
  end
 end
end
