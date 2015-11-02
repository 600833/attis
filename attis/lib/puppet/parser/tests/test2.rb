#!/bin/ruby
$LOAD_PATH<<  Dir.pwd
require 'faunus'
syst='cctv-deployer'
cctv_deployer=Faunus::Maven.new(syst,'1.0.0')
cctv_deployer.deployer_dep_list('/app/puppet','iss_sandbox')
