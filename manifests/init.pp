class pgsql (
  $has_pgsqld = $cconf::has_pgsqld,
  $mountpoint = $cconf::mountpoint,
  $pgsql_version = "10",
  $git_server = $cconf::git_server,
  $nextcloud_server = $cconf::nextcloud_server,
) inherits cconf {

  package { ["postgresql","postgresql-${pgsql_version}"]: }
  file{ "/etc/postgresql": }
  service { "postgresql": }

  file { "/etc/monit/conf-enabled/postgresql": }

  if ( $has_pgsqld ) {

    if ( $git_server != "" ) {
      $git_serverip = $cconf::git_serverip
    }

    if ( $nextcloud_server != "" ) {
      $nextcloud_serverip = $cconf::nextcloud_serverip
    }


    $has_mounts = ( $mountpoint != "" )

    Package["postgresql"] {
      ensure => installed,
    }
    Package["postgresql-${pgsql_version}"] {
      ensure => latest,
    }

    File["/etc/postgresql"] {
      ensure  => directory,
      require => Package["postgresql","postgresql-${pgsql_version}"],
    }

    file { ["/etc/postgresql/${pgsql_version}/main/postgresql.conf", "/etc/postgresql/${pgsql_version}/main/pg_hba.conf"]:
      owner   => "postgres",
      group   => "postgres",
      require => File["/etc/postgresql"],
      notify  => Service["postgresql"],
    }

    File["/etc/postgresql/${pgsql_version}/main/postgresql.conf"] {
      mode    => "644",
      content => epp("pgsql/postgresql.conf.epp"),
    }
    File["/etc/postgresql/${pgsql_version}/main/pg_hba.conf"] {
      mode    => "640",
      content => epp("pgsql/pg_hba.conf.epp"),
    }

    Service["postgresql"] {
      ensure  => running,
      enable  => true,
      require => Package["postgresql","postgresql-${pgsql_version}"],
    }

    File["/etc/postgresql"] -> Service["postgresql"]

    if ( $has_mounts ) {
      Mount["${mountpoint}"] -> Service["postgresql"]
      Mount["${mountpoint}"] ~> Service["postgresql"]
    }
 
    include monitor

    File["/etc/monit/conf-enabled/postgresql"] {
      require => [ File["/etc/monit/monitrc"], Service["postgresql"] ],
      ensure  => present,
      content => epp("pgsql/monit.epp"),
      notify  => Service["monit"],
      before  => Service["monit"],
    }

    exec { "/usr/bin/monit monitor postgresql":
      require => [ File["/etc/monit/conf-enabled/postgresql"], Service["monit"] ],
    }


    if ( $has_mounts ) {
      File["/etc/monit/conf-enabled/${hostname}_mount"] -> File["/etc/monit/conf-enabled/postgresql"]
    }


  }
  
}