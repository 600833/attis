Puppet::Type.type(:kparam).provide(:kparam_provider) do
    desc "provider pour modifier le parametre noyau"
    commands :sysctl=> '/usr/sbin/sysctl'

    def valeur
         puts "target valeur de #{resource[:nom]} : #{resource[:valeur]}"
         z=sysctl(resource[:nom])
         z1=z.match(/\S+\s*=\s*(\S+)/)[1]
         puts "vraie valeur est: #{z1}" 
         z1
    end
    def valeur=(val)
        puts "definir la valeur à #{val}"
        sysctl("#{resource[:nom]}=#{val}")
    end
end
