#!/bin/ruby
$LOAD_PATH<<  Dir.pwd
require 'faunus'
srv='/app/puppet/install/com.thalesgroup.crowd-deployer-deployer-conf/deployer-conf-1.0.0/deployer-conf-1.0.0'
pix = Object.new().extend(Faunus).send 'recursive_directories', srv, 2, false
puts srv
puts
puts pix
