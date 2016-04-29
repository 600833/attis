Facter.add(:installed_conf_list) do
	confine :kernel => "Linux"
	setcode do
		Dir.chdir('/data/maven_repo/com/thalesgroup/')
		Dir.glob('**/*').select { |v| v =~ /version-descriptor\/[^\/]+$/ }.map{|v| v.sub(/\.pom$/,'').sub('/version-descriptor/',': ')}.sort
	end
end
