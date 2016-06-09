#management volume group
Puppet::Type.newtype(:vg) do
begin
 @doc = %Q(Creation d'un groupe de volume lvm2)
 
 ensurable
 newparam(:vgname) do
  isnamevar
  desc "nom du volume groupe"
 end
 newproperty(:disks, :array_matching => :all) do
  desc "disks=['/dev/sda','/dev/sdc']"
  validate { |v|
   raise ArgumentError,"device file is not valid #{v}" unless v =~ /^\/dev\/[vs]d[a-z,0-9]+$/
  }
 end
rescue Exception=>ex
 puts "#####"
 puts ex.message
 puts ex.backtrace
 raise ex
end
end
