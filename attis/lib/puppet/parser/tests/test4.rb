#!/bin/ruby
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

a=[[1,2],[2,4],[4,2],[1,4],[8,9]]

puts a.inspect
puts uniquebyentry(a,2).inspect
