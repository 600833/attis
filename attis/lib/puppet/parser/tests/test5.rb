#!/bin/ruby
$LOAD_PATH<<Dir.pwd
require 'faunus'
a=[[1, 2], [2, 3], [3, 2], [4, 1], [5, 3]]
x=Object.new().extend(Faunus).uniquebyentry(a,1)
puts x.inspect

