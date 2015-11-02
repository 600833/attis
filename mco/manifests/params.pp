class mco::params {
    $activemq_server = "git.ivvq.tss"
    $activemq_mcollective_password = "Passw0rd"
    $package_name = "mcollective"
    $server_service_name = "mcollective"
    $package_ensure = present
    $service_ensure = running
    $service_enabled = true
    $server_config = "server.cfg"
    $server_config_dir= "/etc/mcollective" 
}
