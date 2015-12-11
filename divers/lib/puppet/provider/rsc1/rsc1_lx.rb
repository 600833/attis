Puppet::Type.type(:rsc1).provide(:rsc1_lx) do
    desc "Normal gestion des resources"

    def create
        puts "running create"
         x= @resource.instance_variable_get '@parameters'
#        x.each { |k,v| puts k,v,k.class,v.class }
         puts @resource[:activer]
#        puts @resource.should(:activer)
#        puts @resource.inspect
#        puts self
#        puts self.class
#        puts self.private_methods.inspect
#        puts self.instance_variables.inspect
         activer
         File.open(@resource[:name], "w") { |f| f.puts @activer_drap } #  rajouter drapeau
    end

    def destroy
        puts "running destroy"
        File.unlink(@resource[:name])
    end

    def exists?
        puts "running exists?"
        puts self.private_methods.inspect
        File.exists?(@resource[:name])
    end
    def activer
         puts "running activer"
        case  @resource[:activer]
	 when :true then @activer_drap="drapeau est haut"
	 when :false then @activer_drap="drapeau est bas"
         else @activer_drap="inconnu"
	end
    end
    def activer=(value)
        puts "running activer=xxxx"
        print "activer valeur=",value,"\n"
        @activer_drap=value
    end
end
