require 'tempfile'
module Faunus
  class Exc_maven_get_pom < Exception
  end
  class Exc_maven_list_dep < Exception
  end
  class Exc_maven_subsys_notfound < Exception
  end
  class Maven
   def initialize (tsys,vers,artifact: 'version-descriptor')
    puts '%%%000'
    puts 'Object constant'
    puts Object.constants.inspect
    puts "Process ID"
    x101=Process.pid
    puts x101
    puts  %x( pstree -sp #{x101})
    puts 'environment variables:  '
#    puts ENV.each { | name,value| puts name.inspect + "=" + value.inspect}
    puts  "self=" + self.inspect
    puts  "caller=" + caller.inspect
    puts  "__FILE__= "+__FILE__
    puts '%%%000'
    @tobj_name=tsys
    @tobj_version=vers
    @envcmd={"JAVA_HOME"=>"/app/cots/maven/apache-maven-3.3.3/java/jdk1.7.0_75"}
    @mvnbin="/app/cots/maven/apache-maven-3.3.3/bin"
    cmd_p1="#{@mvnbin}/mvn org.apache.maven.plugins:maven-dependency-plugin:2.4:"
    groupid_p1='com.thalesgroup.'
    groupid=groupid_p1 + tsys
    @mave_repo_base='/data/maven_repo'
    @deployer_dir='/app/puppet/install' 
    @conf_install_dir='/data/puppet/install'
    @hiera_dir='/data/puppet/hiera'
    
    begin
     tf_sys_pom=Tempfile.new('tsys_pom')
     tf_sys_pom.close
     tf_sys_deplist=Tempfile.new('sys_deplist')
     tf_sys_deplist.close
     @cmd_get_p1=cmd_p1 + "get" + " -Dartifact=" + groupid + ':' + artifact + ':' +  vers + ':' + 'pom' + ' -U' + ' -Ddest='
     @cmd_get=@cmd_get_p1 + tf_sys_pom.path
     runcmd = IO.popen(@envcmd,@cmd_get)
     puts ""
     puts "%%% get pom" 
     puts runcmd.readlines
     runcmd.close unless runcmd.closed?
     raise Exc_maven_get_pom," get_pom  #{groupid} #{artifact}: #{@cmd_get}" unless $?.exitstatus == 0
     @cmd_list=cmd_p1 + "list" + " -Dtransitive=true -DoutputFile=" + tf_sys_deplist.path + ' -f ' + tf_sys_pom.path
     runcmd = IO.popen(@envcmd,@cmd_list)
     puts "%%% list dependencies"
     puts runcmd.readlines
     runcmd.close unless runcmd.closed?
     raise Exc_maven_list_dep,"dep_list #{groupid} #{artifact}: #{@cmd_list}" unless $?.exitstatus == 0
     puts ""
     @deplist_1 = File.read(tf_sys_deplist).split(/\n/).select { |v|  v.include?(groupid_p1) }.map { |v| v1=v.strip;v1.split(':') }
    ensure
     puts "%%% deleting temparay files"
     defined? tf_sys_pom and tf_sys_pom.is_a? Tempfile and  tf_sys_pom.unlink
     defined? tf_sys_deplist and tf_sys_deplist.is_a? Tempfile and tf_sys_deplist.unlink
    end
   end
   def bin_dep_list(myline: [])
    @deplist=@deplist_1.map do |v|
     src=@mave_repo_base + '/' + v[0].gsub('.','/') + '/' + v[1] + '/' + v[3] + '/' + v[1] + '-' + v[3] + '.' + v[2]
     m1=v[0].match(/\.([\w\-\_]+)$/)
     m11=m1[1]
     m11='thales/' + m11 unless m11 =~ /cots/
     dst='/app/' + m11 + '/' + v[1] + '-' + v[3]
     case v[2]
     when 'zip' then 
      lnk= '/app/' + m11 + '/' + v[1]
      lnktarget= dst + '/' + v[1] + '-' + v[3]
     when 'war' then
      lnk= '/app/' + m11 + '/' + v[1] + '.war'
      lnktarget= dst + '/' + v[1] + '-' + v[3] + '.war'
     when 'rpm' then
      lnk= '/app/' + m11 + '/' + v[1] + '.rpm'
      lnktarget= dst + '/' + v[1] + '-' + v[3] + '.rpm'
     end
     install_cmd= case v[2]
      when 'rpm' then 'yum localinstall -y ' + src + ' ; ' +  'cp ' + src + ' .'
      when 'zip' then 'unzip ' + src
      when 'war' then 'cp ' + src + ' .'
      else 'inconnu'
     end
     v += [src,dst,install_cmd,lnk,lnktarget]
    end
    @deplist<< myline unless myline.empty?
    @deplist.each { |v| puts v.inspect }
   end

   def deployer_dep_list(conf_dir,puppet_env)
     
    @deplist=@deplist_1.select { |v| v[2] == 'zip' }.map do |v|
     mod_nom=v[1].sub(/[\_\-]*deployer$/,"").gsub(/\-/,"_")
     src=@mave_repo_base + '/' + v[0].gsub('.','/') + '/' + v[1] + '/' + v[3] + '/' + v[1] + '-' + v[3] + '.' + v[2]
#     dst=@deployer_dir + '/' + @tobj_name + '/' +  v[1] + '-' + v[3]
     dst=@deployer_dir + '/' + v[0] +'-'+ v[1] + '/' +  v[1] + '-' + v[3]
     install_cmd= 'unzip ' + src
#     lnk=conf_dir + '/environments/' + puppet_env + '/modules/' + mod_nom
     lnk_dir=conf_dir + '/environments/' + puppet_env + '/modules/'
     lnk_cmd='/bin/ls -1d ' + dst + '/' +  v[1] + '-' + v[3] + '/* | xargs -I% -t ln -sf %'
     v+=[src,dst,install_cmd,lnk_dir,lnk_cmd] 
    end
    @deplist.each { |v| puts v.inspect }
   end

   def conf_dep_list(conf_dir,puppet_env)
     
    @deplist=@deplist_1.select { |v| v[2] == 'zip' }.map do |v|
     mod_nom=v[1].sub(/[\_\-]*conf$/,"").gsub(/\-/,"_")
     src=@mave_repo_base + '/' + v[0].gsub('.','/') + '/' + v[1] + '/' + v[3] + '/' + v[1] + '-' + v[3] + '.' + v[2]
     dst=@conf_install_dir + '/' + @tobj_name + '/' +  v[1] + '-' + v[3]
     install_cmd= 'unzip ' + src
     lnk=conf_dir + '/environments/' + puppet_env + '/modules/' + mod_nom + '/files/' + @tobj_version
     lnktarget=dst + '/' +  v[1] + '-' + v[3] + '/modules/' + mod_nom + '/files/' + @tobj_version
     case mod_nom
      when 'nodes' then
       lnk_hiera=@hiera_dir + '/' +  @tobj_name + '/' + @tobj_version + '/nodes/'
       lnktarget_hiera=dst + '/' +  v[1] + '-' + v[3] + '/hieradata/' + @tobj_name + '/' + @tobj_version + '/nodes/'
      when 'common' then
       lnk_hiera=@hiera_dir + '/' +  @tobj_name + '/' + @tobj_version + '/common'
       lnktarget_hiera=dst + '/' +  v[1] + '-' + v[3] + '/hieradata/' + @tobj_name + '/' + @tobj_version + '/common'
      else
       lnk_hiera=@hiera_dir + '/' +  @tobj_name + '/' + @tobj_version + '/modules/' + mod_nom
       lnktarget_hiera=dst + '/' +  v[1] + '-' + v[3] + '/hieradata/' + @tobj_name + '/' + @tobj_version + '/modules/' + mod_nom
      end
     lnk_hiera_dir=@hiera_dir + '/' +  @tobj_name + '/' + @tobj_version + '/modules'
     v+=[src,dst,install_cmd,lnk,lnktarget,lnk_hiera,lnktarget_hiera,lnk_hiera_dir]
     
    end
    @deplist.each { |v| puts v.inspect }
   end

   def cmd_get
    @cmd_get
   end

   def cmd_list
    @cmd_list
   end 

   def deplist
    @deplist
   end

   def get_cmd_p1
    @cmd_get_p1
   end 

   def get_version(tsubsystem)
    ver1=''
    ligne=[]
    @deplist.each { |v| if (v[1] == tsubsystem) then ligne,ver1 = v, v[3] end }
    raise Exc_maven_subsys_notfound, "Can not find subsystem version for #{tsubsystem} in #{@tobj_name} : #{@tobj_version} in " if ver1.empty?
    return ligne,ver1
   end
  end
 def uniquebyentry(vec,pos)
  tags= Array.new(vec.length) {|v| v=0}
  vec.each_with_index do |v1,ix|
   l1=ix+1
   l2=vec.length - 1
   while  l1 <= l2  
    raise RangeError,"pos: #{pos} out of range" if v1[pos].nil?
    tags[l1]=1 if v1[pos].inspect == vec[l1][pos].inspect
    l1+=1
   end
  end
  vec1=[]
  vec.each_with_index { |v1,ix| vec1<<v1 if tags[ix] !=1 }
  return vec1
 end
 def recursive_directories(pth,start_at,drop_last)
  z=''
  c=File.expand_path(pth).split(/\//).drop(1).collect { |itm| z = z + '/' + itm }
  c1=c.drop(start_at-1)
  c1.delete_at(c1.size-1) if drop_last
  c1
 end 
end
