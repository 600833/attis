#management de fs
require 'etc'
require 'fileutils'
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
  puts "begin creating fs " #{@resource[:name]}"
  x1=vgname
  x2=lvname
  lvcreate('-L',resource[:size],'-n',x2,x1)
  execute ['mkfs -t',resource[:fstype],resource[:device]].join(' ')
  mount_me resource[:mount]
  
 end

 def exists?
=begin
  puts  "provider class: #{self.class}"
  puts  "provider instance methods: #{self.methods.inspect}"
  puts "run fs exists?" 
=end
  puts [' name:',resource[:name],' mnt:',resource[:mnt],' device:',resource[:device],' size:',resource[:size],' owner:',resource[:owner],' group:',resource[:group],' mount?:',resource[:mount]].join

  lvdisplay(resource[:device])
   puts "logical volume #{resource[:device]} found"
   true
  rescue Puppet::ExecutionFailure
   puts "logical volume #{resource[:device]} not found"
   false 
 end
  
 def destroy
  print __method__,' is not implemented','\n'
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
 def mount
   execute ['mount | grep -w ', resource[:mnt]].join(' ')
   puts "#{resource[:mnt]} has been mounted"
   check_owner_group_mode
   return  :true
  rescue Puppet::ExecutionFailure
   puts "#{resource[:mnt]} has been dismounted"
   return  :false
 end
 def mount=(x)
  puts "run mount=#{x}"
  mount_me resource[:mount]
 end
 def check_owner_group_mode
  fstat1 = File.lstat(resource[:mnt])
  cur_gid= fstat1.gid
  cur_uid= fstat1.uid
  cur_mode= '0' + sprintf('%o',fstat1.mode)[-3,3]
  tgt_owner = resource[:owner]
  tgt_owner = tgt_owner.to_s if tgt_owner.is_a? Fixnum
  tgt_owner =~ /^\d+$/ ? tgt_uid = tgt_owner : tgt_uid=Etc.getpwnam(tgt_owner).uid
  tgt_group = resource[:group]
  tgt_group = tgt_group.to_s if tgt_group.is_a? Fixnum
  tgt_group =~ /^\d+$/ ? tgt_gid = tgt_group : tgt_gid=Etc.getgrnam(tgt_group).gid
  tgt_mode = resource[:mode]
  unless cur_mode.to_i(8) == tgt_mode.to_i(8)
   FileUtils.chmod tgt_mode.to_i(8), resource[:mnt]
   puts "#{resource[:mnt]} has been changed from #{cur_mode} to mode #{tgt_mode}"
  end
  unless tgt_uid == cur_uid
   FileUtils.chown tgt_uid, nil, resource[:mnt]
   puts "#{resource[:mnt]} has been changed to owner #{tgt_owner}"
  end
  unless tgt_gid == cur_gid
   FileUtils.chown nil, tgt_gid, resource[:mnt]
   puts "#{resource[:mnt]} has been changed to group #{tgt_group}"
  end
 end
 def mount_me(mount_state_requested)
   if mount_state_requested == :true then
#
#   si on demande que le fs soit monte
#
#   crer  le point de montage s'il n'existe pas
#
    FileUtils.mkdir_p resource[:mnt] unless File.exist? resource[:mnt]
#   monter fs
    puts "begin mounting #{resource[:mnt]}"
    fsmount('-o',resource[:mnt_options],resource[:device],resource[:mnt])
    puts "#{resource[:mnt]} has been mounted" if mount == :true
    fstab(mount_state_requested)
   else
    puts "begin dismounting #{resource[:mnt]}"
    fstab(mount_state_requested)
    execute ['umount ',resource[:mnt]].join(' ')
   end
 end
 def device
  correct_size
  return resource[:device]
 end
 def device=(x)
 end
 def correct_size
  unts={'B'=>1,'K'=>1024,'M'=>1048576,'G'=>1073741824}
  v1=resource[:size].gsub(/\s+/,'')
  v2=v1.match(/^(.+)(.)$/)
  unite=v2[2].upcase
  sizebyte=v2[1].to_f*unts[unite]
  vg1,lv1=resource[:device].split('/').slice(2,2)
  pext=%x(vgs -o vg_extent_size --units B --noheadings #{vg1})
  pext= pext.gsub(/\s/,'')[/^(.+).$/,1].to_f
  nbext= (sizebyte / pext + 0.4999).round
  cur_ext=%x(lvdisplay -c #{@resource[:device]} )
  cur_ext=cur_ext.split(':')[7].to_i
  if  nbext > cur_ext
   lvextend('--extents', nbext.to_s, @resource[:device])
   resize2fs(@resource[:device])
   puts "increased fs #{@resource[:device]} from #{cur_ext} to #{nbext} extents"
  elsif nbext < cur_ext
   raise "reduce fs #{@resource[:device]} from #{cur_ext} to #{nbext} not support"
  else
   puts "fs #{@resource[:device]} unchanged"
  end
 end
 def fstab(mount_state_requested)
  FileUtils.cp('/etc/fstab',"/etc/fstab.puppet.bck."+Time.now.to_f.to_s)
  case  mount_state_requested
  when :false
   sf=File.read('/etc/fstab')
   sf.gsub!(/[^\n]+\s#{resource[:mnt]}\s[^\n]+\n/,'')
   File.open('/etc/fstab','w') {|f| f.puts sf }
  when :true
   sf=File.read('/etc/fstab')
   sf+="\n" unless sf[-1] == "\n"
   sf+=%Q(#{@resource[:device]}  #{@resource[:mnt]}  #{@resource[:fstype]} #{@resource[:mnt_options]} 0 2)
   File.open('/etc/fstab','w') { |f| f.puts sf }
  end
  
 end
end

