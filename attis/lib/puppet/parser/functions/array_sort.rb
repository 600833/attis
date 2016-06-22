#
#sort an array according to regular expression
#
$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
    newfunction(:array_sort, :type => :rvalue) do |args|
      begin
	vec,str=args[0],args[1]
        rg=Regexp.new(str)
        vec.sort! { |k,v| k1=rg.match(k)[1];k2=rg.match(v)[1]; k1<=>k2}
        return  vec
      rescue Exception=>ex
        puts __method__.to_s + ' failed'
        puts ex.message
        puts ex.backtrace
        print 'error type: ',ex.class,"\n"
        raise ex
      end
    end
end
