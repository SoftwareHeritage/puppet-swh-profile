# Ceph OSD profile
class profile::ceph::osd {
  include profile::ceph::base

  $bootstrap_osd_secret = hiera('ceph::secret::bootstrap_osd')
  ::ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_secret,
  }
}
