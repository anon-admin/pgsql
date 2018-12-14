class pgsql::no_pgsql (

) inherits pgsql {

  if ( ! $pgsql::has_pgsqld ) {
    Package["postgresql","postgresql-${pgsql::pgsql_version}"] {
      ensure => purged,
    }

    Service["postgresql"] {
      ensure  => stopped,
      enable  => false,
    }

    File["/etc/monit/conf-enabled/postgresql"] {
      ensure => absent,
    }
  }

}