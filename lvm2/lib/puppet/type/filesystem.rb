#management filesystem
Puppet::Type.newtype(:filesystem) do
begin
 @doc = %Q(Creation d'un system de fichier dans un volume groupe LVM2)
 
 ensurable
 newparam(:fstype) do
  desc "Type de systeme des fichiers exemple: ext4, xfs"
 end
 newparam(:mnt) do
  isnamevar
  desc "point de montage"
 end
=begin
 puts "message from type filesystem"
 puts "%%% Current class:=  #{self}"
 puts "%%% Current ancestors:=  #{self.ancestors}"
=end
 newproperty(:mount) do
  desc "mount=>true or false"
  newvalue(:true)
  newvalue(:false)
 end
 newparam(:owner) do
=begin
  desc "#### owner du point de montage"
  puts "you are in newparam owner"
  puts self.methods.inspect
  puts "___________"
=end
  
  validate { |v|
=begin
   puts "#### you are in newparam validate owner"
   puts self 
   puts self.class
   puts self.methods.inspect
   puts self.private_methods.inspect
   puts "___________"
=end
   unless v.is_a? Fixnum 
    if not ( v =~ /^\w+$/ )
     raise ArgumentError,"owner isn't valid #{v}"
    end
    z=Etc.getpwnam(v)
   else
    z=Etc.getpwuid(v)
   end
  }
 end
 newparam(:group) do
  desc "groupe proprietaire du point de montage"
  validate { |v|
   unless v.is_a? Fixnum
    if not ( v =~ /^\w+$/ )
     raise ArgumentError,"group isn't valid #{v}"
    end
    z=Etc.getgrnam(v)
   else
    z=Etc.getgrgid(v)
   end
  } 
 end
 newparam(:mode) do
  desc "mode du point de montage"
  validate { |v|
   if not ( v =~ /^\d+$/ )
    raise ArgumentError,"mode isn't valid #{v}"
   end
  } 
 end
 newparam(:mnt_options) do
  desc "options de montage"
 end
 newparam(:size) do
  desc "Taille du volume exemple: 10M , ou 1G"
  validate {|v|
   v1=v.gsub(/\s+/,'')
   raise ArgumentError,"size is not valid #{v}" unless v =~ /^(\d+)\.?(\d+)[BKMG]{1}$/i
  }
=begin
  unts={'B'=>1,'K'=>1024,'M'=>1048576,'G'=>1073741824}
  munge { |v|
   v1=v.gsub(/\s+/,'')
   v2=v1.match(/^(.+)(.)$/)
   unite=v2[2].upcase
   sizebyte=v2[1].to_f*unts[unite]
   puts "mounting point: #{@resource[:mnt]} #{@resource[:device]} sizebyte=#{sizebyte}"
   vg1,lv1=resource[:device].split('/').slice(2,2)
   pext=%x(vgs -o vg_extent_size --units B --noheadings #{vg1})
   pext= pext.gsub(/\s/,'')[/^(.+).$/,1].to_f
   nbext= (sizebyte / pext + 0.4999).round
   puts "nbext:= #{nbext}"
   nbext
  }
=end
 end
 newproperty(:device) do
  desc "Fichier special du volume logique example: /dev/datavg/lv_tomcat_data"
  validate { |v|
   raise ArgumentError,"device file is not valid #{v}" unless v =~ /^\/dev\/\w+\/\w+$/
  }
 end
rescue Exception=>ex
 puts "#####"
 puts ex.message
 puts ex.backtrace
 raise ex
end
end
