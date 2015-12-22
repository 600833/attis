$LOAD_PATH<<File.dirname(__FILE__)
require 'faunus'
module Puppet::Parser::Functions
    newfunction(:array_sort, :type => :rvalue) do |args|
      begin
	vec,str=args[0],args[1]
#'(\A.+?)[\s,;]+'
        rg=Regexp.new(str)
#        puts "####self class######"
#        puts self.class 
#        puts self.class.class 
#        puts "###########self.methods##############"
#	puts self.methods
#        puts "###########private.methods##############"
#	puts self.private_methods
#        puts "####self instance_variables ######"
#        puts self.instance_variables
#        puts "#### global variables ##########"
#        puts puts global_variables.inspect
#        puts "#### lookupvar ##########"
#        set_facts({"newfact1"=>"valeurde fact1"})
#        z=lookupvar('newfact1')
#        puts 'getvar newfact1 donne: ',z.inspect
#         print 'environ: ', environment.inspect,"\n"
#         print 'catalog: ', catalog.inspect,"\n"
#         print 'resource: ', resource,"\n"
#        print 'class_scope: ', class_scope,"\n"
#       puts vec.inspect
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
