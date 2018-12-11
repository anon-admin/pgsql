class pgsql::no_pgsql (

) inherits pgsql {

  if ( ! $pgsql::has_pgsqld ) {
    Package["postgresql"] {
      ensure => purged,
    }

    Service["postgresql"] {
      ensure  => stopped,
      enable  => false,
    }
  }

}