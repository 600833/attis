#!/bin/ruby
$:<< Dir.pwd
require 'faunus'
#syst='cctv'
syst='crowd'
cctv=Faunus::Maven.new(syst,'1.0.1')
cctv.bin_dep_list()
puts "===================================="
puts cctv.cmd_get
puts cctv.cmd_list
puts "===================================="
#srv='camera-service'
srv='vcaservice'
ligne,cm_ver=cctv.get_version(srv)
puts "\n"
print 'version:', cm_ver,"\n"
print 'ligne:', ligne.inspect,"\n"
cm=Faunus::Maven.new(syst,cm_ver,artifact: srv)
cm.bin_dep_list(myline: ligne)
puts "===================================="
puts cm.cmd_get
puts cm.cmd_list
puts "===================================="
