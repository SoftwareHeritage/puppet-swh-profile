# Deployment for swh-lister-github
class profile::swh::deploy::worker::swh_lister_github {
  $concurrency = hiera('swh::deploy::worker::swh_lister_github::concurrency')
  $loglevel = hiera('swh::deploy::worker::swh_lister_github::loglevel')
  $task_broker = hiera('swh::deploy::worker::swh_lister_github::task_broker')

  $config_file = '/etc/softwareheritage/lister-github.yml'
  $config = hiera_hash('swh::deploy::worker::swh_lister_github::config')

  $task_modules = ['swh.lister.github.tasks']
  $task_queues = ['swh_lister_github_incremental', 'swh_lister_github_full']

  $packages = ['python3-swh.lister.github']

  package {$packages:
    ensure => 'installed',
  }

  ::profile::swh::deploy::worker::instance {'swh_lister_github':
    ensure       => present,
    concurrency  => $concurrency,
    loglevel     => $loglevel,
    task_broker  => $task_broker,
    task_modules => $task_modules,
    task_queues  => $task_queues,
    require      => [
      Package[$packages],
      File[$config_file],
    ],
  }

  # Contains passwords
  file {$config_file:
    ensure  => 'present',
    owner   => 'swhworker',
    group   => 'swhdev',
    mode    => '0640',
    content => inline_template('<%= @config.to_yaml %>'),
  }
}