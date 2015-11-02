Facter.add(:apply_subsystem_conf_version) do
	confine :kernel => "Linux"
	setcode do
		fact_file='/CONFIG/apply_subsystem_conf_version.fact'
		if File.exists? fact_file then
			t1=File.read(fact_file)
			t1.strip()
		else
			""
		end
	end
end
