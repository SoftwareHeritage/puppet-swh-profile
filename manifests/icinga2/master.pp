# An icinga master host
class profile::icinga2::master {
  $zonename = hiera('icinga2::zonename')
  $zones = hiera('icinga2::zones')
  $endpoints = hiera('icinga2::endpoints')
  $features = hiera('icinga2::features')
  $accept_config = hiera('icinga2::accept_config')

  include profile::icinga2::apt_config

  class {'::icinga2':
    confd     => false,
    features  => $features,
    constants => {
      'ZoneName' => $zonename,
    },
  }

  class { 'icinga2::feature::api':
    accept_config   => $accept_config,
    accept_commands => true,
    endpoints       => $endpoints,
    zones           => $zones,
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }
}
