#!/bin/ruby
$LOAD_PATH<<  Dir.pwd
require 'faunus'
srv='crowd-conf'
cctv_conf=Faunus::Maven.new(srv,'1.0.1')
cctv_conf.conf_dep_list('/app/puppet','iss_sandbox')
