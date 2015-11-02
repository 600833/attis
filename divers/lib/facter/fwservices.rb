require 'pathname'
require 'rexml/document'
def fws
   service_dir='/usr/lib/firewalld/services'
   f_lst=Dir.glob("#{service_dir}/*")
   hh={}
   f_lst.each { |vf|
      tit=Pathname.new(vf).basename.to_s
      t2=tit.sub(/\.\w+$/,"")
      sf=File.read(vf)
      doc=REXML::Document.new(sf)
      a1=Array.new()
      doc.elements.each('service/port') { |v| a1<<v.attributes['port']+"/"+v.attributes['protocol'] }
      hh[t2]=a1
   }
   return hh
end
Facter.add(:fwservices) do
  confine :kernel => "Linux"
  setcode do
   fws
  end
end
