# Deployment for swh-loader-git
class profile::swh::deploy::worker::swh_loader_git {

  include ::profile::swh::deploy::loader

  $concurrency = hiera('swh::deploy::worker::swh_loader_git::concurrency')
  $loglevel = hiera('swh::deploy::worker::swh_loader_git::loglevel')
  $task_broker = hiera('swh::deploy::worker::swh_loader_git::task_broker')

  $config_file = '/etc/softwareheritage/loader/git-updater.yml'
  $config = hiera('swh::deploy::worker::swh_loader_git::config')

  $task_modules = ['swh.loader.git.tasks']
  $task_queues = ['swh_loader_git']

  $packages = ['python3-swh.loader.git']

  package {$packages:
    ensure => 'installed',
  }

  ::profile::swh::deploy::worker::instance {'swh_loader_git':
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

  file {$config_file:
    ensure  => 'present',
    owner   => 'swhworker',
    group   => 'swhworker',
    mode    => '0644',
    content => inline_template('<%= @config.to_yaml %>'),
  }
}