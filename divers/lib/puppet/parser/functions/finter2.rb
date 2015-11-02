require 'logger'
def finter2(frm,fct)
	$LG=Logger.new("/var/log/puppet/functions.log",10000000)
       	new_inter=frm.map do |s|
               	h={}
               	fct.each do |s2|
                       	h = s.merge({"dvname"=> s2["dvname"]}) if s2["macaddress"] == s["mac"]
              	end 
                h
        end 
	$LG.info("new_inter: #{new_inter}")
       	return new_inter
end
