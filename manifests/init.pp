class vyatta (
  $script_dir = '/tmp',
  $configuration = '/config/config.puppet',
  $host_name = $hostname,
  $time_zone = $timezone,
  $vyatta_prefix = '/opt/vyatta'
) {
  concat { $configuration:
    owner => root,
    group => root,
    mode  => '0644',
#    notify => Exec["vyatta_loadFile.sh ${configuration}"]
  }
  concat::fragment { "interfaces_header":
    target  => "${vyatta::configuration}",
    content => template('vyatta/interfaces_header.erb'),
    order   => 200,
  }
  concat::fragment { "interfaces_trailer":
    target  => "${vyatta::configuration}",
    content => template('vyatta/interfaces_trailer.erb'),
    order   => 299,
  }
  concat::fragment { "system_header":
    target  => "${vyatta::configuration}",
    content => template('vyatta/system_header.erb'),
    order   => 500,
  }
  concat::fragment { "system_trailer":
    target  => "${vyatta::configuration}",
    content => template('vyatta/system_trailer.erb'),
    order   => 599,
  }
  concat::fragment { "service_header":
    target  => "${vyatta::configuration}",
    content => template('vyatta/service_header.erb'),
    order   => 400,
  }
  concat::fragment { "service_trailer":
    target  => "${vyatta::configuration}",
    content => template('vyatta/service_trailer.erb'),
    order   => 499,
  }
  concat::fragment { "protocols_header":
    target  => "${vyatta::configuration}",
    content => template('vyatta/protocols_header.erb'),
    order   => 600,
  }
  concat::fragment { "protocols_trailer":
    target  => "${vyatta::configuration}",
    content => template('vyatta/protocols_trailer.erb'),
    order   => 699,
  }
  file { "${script_dir}/vyatta_end_session.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0744',
    source => 'puppet:///modules/vyatta/vyatta_end_session.sh'
  }
  file { "${script_dir}/vyatta_loadFile.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0744',
    source => 'puppet:///modules/vyatta/vyatta_loadFile.sh',
    require => [File["${script_dir}/vyatta_end_session.sh"],File["${script_dir}/vyatta_setup_session.sh"]]
  }
  file { "${script_dir}/vyatta_setup_session.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0744',
    source => 'puppet:///modules/vyatta/vyatta_setup_session.sh',
    require => File["${script_dir}/vyatta_snippet.sh"]
  }
  file { "${script_dir}/vyatta_snippet.sh":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0744',
    source => 'puppet:///modules/vyatta/vyatta_snippet.sh'
  }
  exec { "vyatta_loadFile.sh ${configuration}":
    path        => $script_dir,
    environment => ["vyatta_prefix=${vyatta_prefix}","vyatta_htmldir=${vyatta_prefix}/share/html","vyatta_datadir=${vyatta_prefix}/share","vyatta_op_templates=${vyatta_prefix}/share/vyatta-op/templates","vyatta_sysconfdir=${vyatta_prefix}/etc","vyatta_sharedstatedir=${vyatta_prefix}/com","vyatta_sbindir=${vyatta_prefix}/sbin","vyatta_cfg_templates=${vyatta_prefix}/share/vyatta-cfg/templates",'VYATTA_CFG_GROUP_NAME=vyattacfg',"vyatta_bindir=${vyatta_prefix}/bin","VYATTA_USER_LEVEL_DIR=${vyatta_prefix}/etc/shell/level/admin","vyatta_libdir=${vyatta_prefix}/lib","vyatta_localstatedir=${vyatta_prefix}/var","vyatta_libexecdir=${vyatta_prefix}/libexec","vyatta_datarootdir=${vyatta_prefix}/share","vyatta_configdir=${vyatta_prefix}/config","vyatta_infodir=${vyatta_prefix}/share/info","vyatta_localedir=${vyatta_prefix}/share/locale"],
    logoutput   => true,
    subscribe   => Concat[$configuration],
    refreshonly => true,
    require     => File["${script_dir}/vyatta_loadFile.sh"]
  }
}
