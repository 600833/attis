#!/bin/ruby
def itemize(x)
raise "x is not string" unless x.is_a? String
y=x.chomp
y1=y.split(/[ ;,]+/)
return y1
end
puts "insert a string"
x=STDIN.gets
puts itemize(x).inspect
