class puppet::config inherits puppet {
  file { 'puppet_config':
    path     => "${puppet_config}",
    ensure   => file,
    owner    => 0,
    group    => 0,
    mode     => '0644',
    content  => template("puppet/puppet.conf.erb"),
    notify   => Exec['restart_puppet'],
  }
  file { 'puppet_auth':
    ensure => file,
    path => "${puppet_auth}",
    owner => 0,
    group => 0,
    mode => '0644', 
    content => template("puppet/auth.conf.erb"),
    notify => Exec['restart_puppet'],
  }
  file { $puppetagent_option_file:
    owner=> 0,
    group=> 0,
    mode=> '0644',
    content=> template("puppet/puppetagent.erb"),
    notify => Exec['restart_puppet'],
  }
}
