# Setup nftables on a host
class sunet::nftables::init(
  Boolean $default_log = true,
) {
  if $::facts['sunet_nftables_enabled'] == 'yes' {
    package { 'nftables':
        ensure => 'present',
    }

    file { '/etc/nftables/':
        ensure => 'directory',
    }

    file { '/etc/nftables/conf.d/':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/sunet/nftables/nftables-conf.d-empty',
        notify => Service['nftables'],
    }

    if ($default_log) {
      file { '/etc/nftables/conf.d/999-log.nft':
        ensure => 'present',
        mode   => '0644',
        source => 'puppet:///modules/sunet/nftables/999-log.nft',
        notify => Service['nftables'],
      }
    }

    file { '/etc/nftables.conf':
        ensure => 'present',
        mode   => '0755',
        source => 'puppet:///modules/sunet/nftables/nftables.conf',
        notify => Service['nftables'],
    }

    service { 'nftables':
        ensure => 'running',
        enable => true,
    }
  } else {
    package { 'nftables':
        ensure => 'absent',
    }
    if ($default_log) {
      file { '/etc/nftables/conf.d/999-log.nft':
        ensure => 'absent',
      }
    }

    file { '/etc/nftables/conf.d/':
        ensure => 'absent',
    }
    -> file { '/etc/nftables/':
        ensure => 'absent',
    }

    file { '/etc/nftables.conf':
        ensure => 'absent',
    }

    service { 'nftables':
        ensure => 'disabled',
    }
  }
}
