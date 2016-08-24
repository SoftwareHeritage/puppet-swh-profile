# Deployment of the swh.objstorage.api server

class profile::swh::deploy::objstorage::log_checker {
  $conf_directory = hiera('swh::deploy::objstorage::log_checker::conf_directory')
  $conf_file = hiera('swh::deploy::objstorage::log_checker::conf_file')
  $user = hiera('swh::deploy::objstorage::log_checker::user')
  $group = hiera('swh::deploy::objstorage::log_checker::group')

  # configuration file
  $directory = hiera('swh::deploy::objstorage::log_checker::directory')
  $slicing = hiera('swh::deploy::objstorage::log_checker::slicing')
  $checker_class = hiera('swh::deploy::objstorage::log_checker::class')
  $batch_size = hiera('swh::deploy::objstorage::log_checker::batch_size')
  $log_tag = hiera('swh::deploy::objstorage::log_checker::log_tag')

  $swh_packages = ['python3-swh.objstorage']

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
    content => template('profile/swh/deploy/storage/objstorage_log_checker.erb'),
    notify  => Service['uwsgi'],
  }

  include ::systemd

  file {'/etc/systemd/system/objstorage_log_checker.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profile/swh/deploy/storage/objstorage_log_checker.service.erb'),
    notify  => Exec['systemd-daemon-reload'],
    require => File[$conf_file],
  }

}