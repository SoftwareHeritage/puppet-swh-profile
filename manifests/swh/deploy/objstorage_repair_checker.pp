# Deployment of the swh.objstorage.checker.RepairContentChecker

class profile::swh::deploy::objstorage_repair_checker {
  $conf_directory = hiera('swh::deploy::objstorage_repair_checker::conf_directory')
  $conf_file = hiera('swh::deploy::objstorage_repair_checker::conf_file')
  $user = hiera('swh::deploy::objstorage_repair_checker::user')
  $group = hiera('swh::deploy::objstorage_repair_checker::group')

  # configuration file
  $directory = hiera('swh::deploy::objstorage_repair_checker::directory')
  $slicing = hiera('swh::deploy::objstorage_repair_checker::slicing')
  $checker_class = hiera('swh::deploy::objstorage_repair_checker::class')
  $batch_size = hiera('swh::deploy::objstorage_repair_checker::batch_size')
  $log_tag = hiera('swh::deploy::objstorage_repair_checker::log_tag')

  $swh_packages = ['python3-swh.objstorage.checker']

  package {$swh_packages:
    ensure  => latest,
    require => Apt::Source['softwareheritage'],
  }

  file {$conf_directory:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0750',
  }

  file {$conf_file:
    ensure  => present,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    content => template('profile/swh/deploy/storage/objstorage_repair_checker.yml.erb'),
  }

  include ::systemd

  file {'/etc/systemd/system/objstorage_repair_checker.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profile/swh/deploy/storage/objstorage_repair_checker.service.erb'),
    notify  => Exec['systemd-daemon-reload'],
    require => [
      File[$conf_file],
      Package[$swh_packages],
    ]
  }

}