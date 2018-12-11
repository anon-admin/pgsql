class pgsql (
  $has_pgsqld = $cconf::has_pgsqld,
  $mountpoint = $cconf::mountpoint,
) inherits cconf {

  package { "postgresql": }

  service { "postgresql": }

  if ( $has_pgsqld ) {

    $has_mounts = ( $mountpoint != "" )

    Package["postgresql"] {
      ensure => latest,
    }

    Service["postgresql"] {
      ensure  => running,
      enable  => true,
      require => Package["postgresql"],
    }

    if ( $has_mounts ) {
      Mount["${mountpoint}"] -> Service["postgresql"]
      Mount["${mountpoint}"] ~> Service["postgresql"]
    }
 
    include monitor

    file { "/etc/monit/conf-enabled/postgresql":
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