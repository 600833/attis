$LOAD_PATH<<File.dirname(__FILE__)
module Puppet::Parser::Functions
 newfunction(:foreman_netconfig, :type => :rvalue) do |args|
 begin
  type_op=args[0]
  case type_op
  when /list/i then
   puts '========================================='
   puts 'method :' +__method__.inspect
   puts 'class :' + self.class.inspect
   puts 'class or module :' + self.class.class.inspect
   puts 'ancestors: ',self.class.ancestors.inspect
#  puts 'object_methods : ',self.methods.inspect
   puts 'object_id : '+__id__.inspect
   puts '========================================='
   unless defined? @foreman_interfaces
    @foreman_interfaces||=lookupvar('foreman_interfaces')
    @facts||=lookupvar('facts')
#
# complete macaddress or identifier
#
    @foreman_interfaces.each_with_index do |v,i|
      puts v.inspect
      puts 'completing macaddress'
      raise "Network interface mac and identifier are unknown" if ( (v['mac'].nil? or v['mac'].empty?) and (v['identifier'].nil? or v['identifier'].empty?) )
      if v['mac'].nil? or v['mac'].empty?
       idf=v['identifier'].gsub(/\./,'_')
       cle='macaddress_' + idf
       v['mac']=@facts[cle]
       raise "Network interface with identifier #{idf} has no macaddress" if v['mac'].nil? or v['mac'].empty?
       puts "identifier #{idf} has macaddress #{v['mac']}"
      end
#
#
#
      puts 'completing identifier'
      if v['identifier'].nil? or v['identifier'].empty?
        xmac=v['mac']
        all_macs=@facts.select { |k,v| k =~ /^macaddress_/ }
        tri_1=all_macs.select { |k,v| v.downcase == xmac.downcase }
#
#unique mac
#
        if tri_1.size == 1
         v['identifier']=tri_1.keys[0].match(/macaddress_(\S+)/)[1]
         puts "macaddress #{xmac} #{v['identifier']}"
#
#bonding
#
        elsif v['type'].upcase == 'BOND'
         tri_2=tri_1.select { |k,v| k =~ /^macaddress_bond/ }
          if tri_2.size == 1
           v['identifier']=tri_2.keys[0].match(/macaddress_(\S+)/)[1]
           puts "macaddress #{xmac} #{v['identifier']}"
          end 
#
#no bonding or no aggregate
#
        elsif v['type'].upcase == 'INTERFACE'
#
#virtual interface
#
         if v['virtual'] == true
          tri_2=tri_1.select { |k,v| k =~ /^macaddress_(\w+_)/ }
          if tri_2.size == 1
           id2=tri_2.keys[0].match(/macaddress_(\S+)/)[1]
#
#sub-interface
#
           if v['tag'].nil? or  v['tag'].empty?
            v['identifier']=id2.gsub('_',':')
            puts "macaddress #{xmac} #{v['identifier']}"
#
#vlan tag interface
#
           else
            v['identifier']=id2.gsub('_','.')
            puts "macaddress #{xmac} #{v['identifier']}"
           end
          end
#
# virtual=false interface
#
         else
          tri_2=tri_1.select { |k,v| k =~ /^macaddress_([^_]+)$/ }
          if tri_2.size == 1
           v['identifier']=tri_2.keys[0].match(/macaddress_(\S+)/)[1]
           puts "macaddress #{xmac} #{v['identifier']}"
          end
         end
        end
      end
    end 
#
# interface classification
#
    puts 'interfaces classification'
    @foreman_interfaces.each_with_index do |v,i|
     v['slave_index']=Array.new()
     v['maitre_index']=''
     v['rt_index']=i
    end 
    @foreman_interfaces.each_with_index do |v,i|
     if v['type'].upcase == 'BOND'
      v['classe']='aggregate'
      if not (v['attached_devices'].nil? ) and not(v['attached_devices'].empty?)
       v['attached_devices'].split(/[\s,;]+/).each do | w |
        @foreman_interfaces.each_with_index do |x,j|
         if x['identifier'] == w
          v['slave_index'].push(j)
          x['classe'],x['maitre_index']='slave',i
         end
        end
       end
      end
     elsif v['type'].upcase == 'INTERFACE' and  v['virtual'] == true and (v['tag'].nil? or  v['tag'].empty?)
      v['classe']='subinterface'
     elsif v['type'].upcase == 'INTERFACE' and  v['virtual'] == true and (not(v['tag'].nil?) and not( v['tag'].empty?) )
      v['classe']='vlan'
      v['id_vlan']=v['tag']
     end
    end
    @foreman_interfaces.each_with_index do |v,i|
     v['classe']='standard' if v['classe'].nil?
    end
#
# detecting duplicate identifier
#
    @foreman_interfaces.each_with_index do |v,i|
     v['missing']=Array.new
     v['critic']='no' 
     if v['identifier'].nil? or v['identifier'].empty?
      v['missing'].push('no_identifier')
      v['critic']='yes' 
     end
     if v['ip'].nil? or v['ip'].empty?
      v['missing'].push('no_ip')
     end
     if v['mac'].nil? or v['mac'].empty?
      v['missing'].push('no_macaddress')
      v['critic']='yes' 
     end
     if v['subnet'].nil?
      v['missing'].push('no_subnet')
     elsif v['subnet']['mask'].nil? or v['subnet']['mask'].empty?
      v['missing'].push('no_subnet_mask')
     elsif v['subnet']['gateway'].nil? or v['subnet']['gateway'].empty?
      v['missing'].push('no_gateway')
     end
    end
    valid_id_list=@foreman_interfaces.select { |v| v['missing'].empty? == false and v['missing'].grep(/no_identifier/).empty? == true }.map { |v| v['identifier']}
    duplicate_id_list=valid_id_list.select { |v| valid_id_list.count(v) > 1 }
    puts "list of duplicated identifier : " + duplicate_id_list.inspect
    @foreman_interfaces.each_with_index do |v,i|
     unless duplicate_id_list.grep(/^#{v['identifier']}$/).empty?
      v['missing'].push('identifier_duplicated')
      v['critic']='yes'
     end
    end
    @simple_interfaces=Array.new()
    @foreman_interfaces.each_with_index do |v,i|
     @simple_interfaces.push({:i=>i,:mac=>v['mac'],:identifier=>v['identifier'],:type=>v['type'],:virtual=>v['virtual'],:ip=>v['ip'],:classe=>v['classe'],:missing=>v['missing'],:maitre_index=>v['maitre_index'],:slave_index=>v['slave_index'],:critic=>v['critic']})
    end
    puts "important interfaces attributes:"
    @simple_interfaces.each { |v| puts v.inspect}
   end
   @foreman_interfaces.each do |v|
    if v['classe']=='subinterface'
     v['identifier'].gsub!('.',':')
    end
   end
   @foreman_interfaces.each { |v| v.delete('attrs');puts v.inspect }
   @foreman_interfaces
  else
  end
 rescue Exception => e
  puts e.message
  puts e.backtrace
  puts caller
  raise e
 end
 end
end
