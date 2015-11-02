Facter.add(:hostgroup) do
	confine :kernel => "Linux"
	setcode do
		fact_file='/CONFIG/hostgroup.fact'
		if File.exists? fact_file
			t1=File.read(fact_file)
			t=t1.strip()
		else
			""
		end
	end
end
