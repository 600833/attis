#management de fs
require 'etc'
require 'fileutils'
Puppet::Type.type(:vg).provide(:lvm2_vg) do
 commands :vgcreate   => 'vgcreate',
          :pvcreate   => 'pvcreate',
          :vgextend   => 'vgextend',
          :vgreduce   => 'vgreduce',
          :pvs        => 'pvs',
          :vgs        => 'vgs',
          :vgremove   => 'vgremove'
           
 def create
  puts "begin creating vg  #{resource[:vgname]}"
  vgcreate(resource[:vgname],resource[:disks])
 end

 def exists?
  puts [' vg:',resource[:vgname],' target disks:',resource[:disks]].join(' ')
  vgs(resource[:vgname])
   puts "vg #{resource[:vgname]} found"
   true
  rescue Puppet::ExecutionFailure
   puts "volume group #{resource[:vgname]} not found"
   false 
 end
  
 def destroy
  puts "destroy disks"
  vgremove('--force',resource[:vgname])
 end
 def vg2pv
  z=%x(pvs  --noheadings)
  z1=z.lines
  vg_pv=z1.collect { |v| v.chomp; v.match(/\s*(\S+)\s+(\S+)/)[1,2].rotate}
 end
 def disksofvg vgname
  vg_pv=vg2pv
  real_pvs=vg_pv.select {|k| k[0] == resource[:vgname]}.map { |k| k[1]}.sort
 end

 def disks
  real_pvs= disksofvg resource[:vgname]
  target_pvs=resource[:disks].sort 
  if real_pvs == target_pvs then
   resource[:disks]
  else
   real_pvs
  end
 end
 def disks=(x)
  puts "vg reconfiguration to target disks#{x.inspect}"
  real_pvs=disksofvg resource[:vgname]
  target_pvs=resource[:disks].sort
  if target_pvs.empty? then
   puts "remove vg #{resource[:vgname]}" 
   vgremove(resource[:vgname])
  end
  to_add_pv=target_pvs - real_pvs
  to_add_pv.each do |dsk|
   puts "add #{dsk} to vg #{resource[:vgname]}" 
   vgextend(resource[:vgname], dsk)
  end
  pv_to_remove=real_pvs - target_pvs
  pv_to_remove.each do |dsk|
   puts "remove #{dsk} from vg #{resource[:vgname]}" 
   vgreduce(resource[:vgname], dsk) 
  end
 end
end
