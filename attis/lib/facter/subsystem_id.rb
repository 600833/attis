Facter.add(:subsystem_id) do
	confine :kernel => "Linux"
	setcode do
		fact_file='/CONFIG/subsystem_id.fact'
		if File.exists? fact_file then
			t1=File.read(fact_file)
			t1.strip()
		else
			""
		end
	end
end
