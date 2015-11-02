require "json"
lst=[]
z=%x(lspci -vmm -Dk)
z1=z.split(/(Slot:\s+\h+:\h+:\h+\.\h)/)
z1.each_with_index do | s,i |
	case s
	when /(ethernet|scsi|Host bridge|smart array)/i
                l1=z1[i-1].strip
		s1=s.strip
		m1=/(\h+:\h+:\h+\.\h)/.match(l1)
		pcislot=$1
		s2 = s1.split(/[\n]/)
		s5 = '{ "pcislot": "' + pcislot + '"'
		s2.each_with_index do | s3,j|
			s4=s3.split(/[:]/)
			n1=s4[0].strip
			v1=s4[1].strip
			s5 = s5 + ', "' + n1.downcase + '": "' + v1 + '"'
		end
                s5 = s5 + "}" 
		p2 = JSON.parse(s5)
		case s
		when /ethernet/i
			dir1="/sys/bus/pci/drivers/"+p2["driver"]+"/"+p2["pcislot"]+"/net/"
			dvname=Dir.entries(dir1).reject { |a|  a =~ /^\./}[0]
			faddr=dir1+"/"+dvname+"/address"
			adr=""
			File.open(faddr,"r") do |pf|
				adr=pf.gets		
			end
			p2["dvname"]=dvname
			p2["macaddress"]=adr.strip
		end
		case s
		when /(scsi|smart array)/i
			x1=%x(find /sys/block -ls ).split(/\n/).select { |a| a.include?(pcislot)}
			x1=x1.map{ |a| x=/\/(\w+)$/.match(a);x[1]}
			p2["disks"]=x1
		end
		lst << p2
                
	end
end
Facter.add(:pcidevices) do
	confine :kernel => "Linux"
	setcode do
		lst
	end
end
