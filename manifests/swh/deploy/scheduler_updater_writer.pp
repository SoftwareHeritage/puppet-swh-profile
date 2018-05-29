# Deployment of swh-scheduler-writer related utilities
class profile::swh::deploy::scheduler::updater::writer {
  include ::profile::swh::deploy::scheduler::updater

  $writer_conf_dir = lookup('swh::deploy::scheduler::updater::writer::conf_dir')
  $writer_conf_file = lookup('swh::deploy::scheduler::updater::writer::conf_file')
  $writer_user = lookup('swh::deploy::scheduler::updater::writer::user')
  $writer_group = lookup('swh::deploy::scheduler::updater::writer::group')
  $writer_config = lookup('swh::deploy::scheduler::updater::writer::config')

  file {$writer_conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => $writer_group,
    mode   => '0755',
  }

  file {$writer_config:
    ensure  => present,
    owner   => 'root',
    group   => $writer_group,
    mode    => '0640',
    content => inline_template("<%= @writer_config.to_yaml %>\n"),
  }

  # unit + timer
  writer_service = 'swh-scheduler-updater-writer'
  writer_unit_name = "${writer_service}.service"
  # Service to consume from ghtorrent
  ::systemd::unit_file {$writer_unit_name:
    ensure  => present,
    content => template("profile/swh/deploy/scheduler/${writer_unit_name}.erb"),
  } ~> service {$writer_service:
    enable => true,
  }

  writer_timer_period = lookup('swh::deploy::scheduler::writer::timer_period')
  writer_timer = 'swh-scheduler-updater-writer'
  writer_timer_unit_name = "${writer_timer}.timer"
  ::systemd::unit_file {$writer_timer_unit_name:
    ensure  => present,
    content => template("profile/swh/deploy/scheduler/${writer_timer_unit_name}.erb"),
  } ~> service {$writer_service:
    enable => true,
  } ~> service {$writer_timer:
    ensure  => running,
    enable  => true,
    require => Service[$ghtorrent_service_name],
  }

}
