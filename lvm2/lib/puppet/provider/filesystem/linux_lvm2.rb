#management de fs
Puppet::Type.type(:filesystem).provide(:linux_lvm2) do
 commands :lvcreate   => 'lvcreate',
          :lvremove   => 'lvremove',
          :lvextend   => 'lvextend',
          :lvs        => 'lvs',
          :resize2fs  => 'resize2fs',
          :fsmount     => 'mount',
          :blkid      => 'blkid',
          :dmsetup    => 'dmsetup',
          :lvconvert  => 'lvconvert',
          :lvdisplay  => 'lvdisplay'

           
 def create
  puts "Creer du fichier de system" #{@resource[:name]}"
  x1=vgname
  x2=lvname
  lvcreate('-L',resource[:size],'-n',x2,x1)
  execute ['mkfs -t',resource[:fstype],resource[:device]].join(' ')
  FileUtils.mkdir_p resource[:mnt]
  mount_me resource[:mount]
  
 end

 def exists?
  puts "exists" 
  puts resource[:name]
  puts resource[:mnt]
  puts resource[:device]
  puts resource[:size]
  puts resource[:fstype]
  puts resource[:owner]
  puts resource[:group]
  puts resource[:mnt_options]
  puts resource[:mount],resource[:mount].class
  puts "valeur montage " + mount.to_s

  lvdisplay(resource[:device])
     puts "lv #{resource[:device]} existe deja"
     puts $?
     true
  rescue Puppet::ExecutionFailure
    puts $?
    puts "ca nexiste pas"
    false 
 end
  
 def destroy
  print __method__,' is not implemented','\n'
 end

 def size
  puts "get size" 
 end
 def size=(x)
  puts "size=(x)" 
 end
 def owner
  puts "get owner" 
 end
 def group
  puts "get group" 
 end
 def owner=(x)
  puts "owner=(x)" 
 end
 def group=(x)
  puts "group=(x)" 
 end
 def mount
  puts "get mount"
  execute ['mount | grep -w ', resource[:mnt]].join(' ')
  puts "deja monte"
  
  if resource[:mount] == true
   return  false
  else
    mount_me resource[:mount]
  end 
  rescue Puppet::ExecutionFailure
   puts "pas monte"
   return  (resource[:mount] == false) ? true : false
 end
 def mount=(x)
  puts "mount=#{x}"
  mount_me resource[:mount]
 end
 def fs_uuid
  puts "fs_uuid" 
 end
 def lvname
  x=resource[:device].match(/^\/(.+)\/(.+)\/(.+)$/)[3]
  puts "lvname " + x
  return x
 end 
 def vgname
  x=resource[:device].match(/^\/(.+)\/(.+)\/(.+)$/)[2]
  puts "vgname " + x
  return x
 end 
 def mount_me(faire)
   if faire
    fsmount('-o',resource[:mnt_options],resource[:device],resource[:mnt])
   else
    execute 'umount ' + resource[:mnt]
   end
 end

end
