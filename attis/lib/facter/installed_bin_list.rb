Facter.add(:installed_bin_list) do
	confine :kernel => "Linux"
	setcode do
		Dir.chdir('/data/maven_repo/com/thalesgroup/')
		Dir.glob('**/*.pom').map { |v| v.sub(/\.pom$/,'')}.sort
	end
end
