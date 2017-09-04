# Base configuration for Software Heritage servers
class profile::base {
  class { '::ntp':
    servers => hiera('ntp::servers'),
  }

  class { '::postfix':
    relayhost          => hiera('smtp::relayhost'),
    mydestination      => hiera_array('smtp::mydestination'),
    mynetworks         => hiera_array('smtp::mynetworks'),
    relay_destinations => hiera_hash('smtp::relay_destinations'),
    virtual_aliases    => hiera_hash('smtp::virtual_aliases'),
  }

  exec {'newaliases':
    path        => ['/usr/bin', '/usr/sbin'],
    refreshonly => true,
    require     => Package['postfix'],
  }

  $mail_aliases = hiera_hash('smtp::mail_aliases')
  each($mail_aliases) |$alias, $recipients| {
    mailalias {$alias:
      ensure    => present,
      recipient => $recipients,
      notify    => Exec['newaliases'],
    }
  }

  class { '::locales':
    default_locale => hiera('locales::default_locale'),
    locales        => hiera('locales::installed_locales'),
  }

  $packages = hiera_array('packages')

  package { $packages:
    ensure => present,
  }

  $users = hiera_hash('users')
  $groups = hiera_hash('groups')

  each($groups) |$name, $data| {
    group { $name:
      ensure => 'present',
      gid    => $data['gid'],
    }
  }

  each($users) |$name, $data| {
    if $name == 'root' {
      $home = '/root'
      $mode = '0600'
    } else {
      $home = "/home/${name}"
      $mode = '0644'
    }

    user { $name:
      ensure   => 'present',
      uid      => $data['uid'],
      comment  => $data['full_name'],
      shell    => $data['shell'],
      groups   => $data['groups'],
      password => $data['password'],
      require  => Group[$data['groups']],
    }

    if ($data['shell'] == '/usr/bin/zsh') {
      Package['zsh'] -> User[$name]
    }

    if (has_key($groups, $name)) {
      Group[$name] -> User[$name]
    }

    file { $home:
      ensure  => 'directory',
      mode    => $mode,
      owner   => $name,
      group   => $name,
      require => User[$name],
    }
  }

  class { '::sudo':
    config_file_replace => false,
    purge               => false,
  }

  ::sudo::conf { 'local-env':
    ensure   => present,
    content  => 'Defaults        env_keep += "GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL"',
    priority => 10,
  }

  ::sudo::conf { 'local-deploy':
    ensure   => present,
    content  => '%swhdeploy  ALL = NOPASSWD: /usr/local/sbin/swh-puppet-master-deploy, /usr/local/sbin/swh-puppet-test, /usr/local/sbin/swh-puppet-apply, /usr/bin/apt-get update',
    priority => 20,
  }

  class {'::timezone':
    timezone => hiera('timezone'),
  }

  $bind_autogenerate = hiera_hash('bind::autogenerate')
  $bind_key = hiera('bind::update_key')

  each($bind_autogenerate) |$net, $zone| {
    $ipaddr = ip_for_network($net)
    if $ipaddr {
      $reverse = reverse_ipv4($ipaddr)
      $fqdn = "${::hostname}.${zone}"

      @@resource_record { "${::hostname}/${zone}/A":
        type    => 'A',
        record  => $fqdn,
        data    => $ipaddr,
        keyfile => "/etc/bind/keys/${bind_key}",
      }

      @@resource_record { "${::hostname}/${zone}/PTR":
        type    => 'PTR',
        record  => $reverse,
        data    => "${fqdn}.",
        keyfile => "/etc/bind/keys/${bind_key}",
      }
    }
  }
}
