# Deployment of swh.storage.archiver.director instance
# Only asynchronous version possible.
# Cron not installed since we need to run one synchronous batch first
# to catch up

class profile::swh::deploy::storage::archiver {
  $conf_directory = hiera('swh::deploy::storage::archiver::conf_directory')
  $conf_file = hiera('swh::deploy::storage::archiver::conf_file')
  $user = hiera('swh::deploy::storage::archiver::user')
  $group = hiera('swh::deploy::storage::archiver::group')

  $objstorage_path = hiera('swh::deploy::storage::archiver::objstorage_path')
  $batch_max_size = hiera('swh::deploy::storage::archiver::batch_max_size')
  $archival_max_age = hiera('swh::deploy::storage::archiver::archival_max_age')
  $retention_policy = hiera('swh::deploy::storage::archiver::retention_policy')
  $db_host = hiera('swh::deploy::storage::archiver::db::host')
  $db_user = hiera('swh::deploy::storage::archiver::db::user')
  $db_dbname = hiera('swh::deploy::storage::archiver::db::dbname')
  $db_password = hiera('swh::deploy::storage::archiver::db::password')

  $log_file = hiera('swh::deploy::storage::archiver::log::file')

  $swh_packages = ['python3-swh.storage']

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
    content => template('profile/swh/deploy/storage/archiver.ini.erb'),
    require => [
      File[$conf_directory],
      Package[$swh_packages],
    ]
  }

  # cron {'swh-storage-archiver':
  #   ensure   => present,
  #   user     => $user,
  #   command  => "/usr/bin/python3 -m swh.storage.archiver.director --config-path ${conf_file} --async 2>&1 > ${log_file}",
  #   hour     => fqdn_rand(24, 'stats_export_hour'),
  #   minute   => fqdn_rand(60, 'stats_export_minute'),
  #   month    => '*',
  #   monthday => '*',
  #   weekday  => '*',
  #   require  => [
  #     File[$conf_file]
  #   ]
  # }

}
