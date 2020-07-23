# Create a shellscript to automatically upgrade OS packages, and optionally run it from cron.
class sunet::updater(
  Boolean $cosmos_automatic_reboot = false,
  Boolean $cron   = false,
  String  $hour   = '4',
  String  $minute = '2',
) {
  file {'/usr/local/sbin/silent-update-and-upgrade':
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('sunet/updater/silent-update-and-upgrade.erb'),
  }
  if ($cosmos_automatic_reboot) {
    file {'/etc/cosmos-automatic-reboot':
      content => "# generated by sunet::updater - do not edit or remove by hand\n"
    }
  } else {
    file {'/etc/cosmos-automatic-reboot': ensure => absent }
  }
  cron { 'silent-update-and-upgrade': ensure => absent }
  file { '/etc/scriptherder/check/upgrader.ini': ensure => absent }
  if ($cron) {
    sunet::scriptherder::cronjob { 'update_and_upgrade':
      cmd           => '/usr/local/sbin/silent-update-and-upgrade --random-sleep',
      minute        => $minute,
      hour          => $hour,
      ok_criteria   => ['exit_status=0', 'max_age=25h'],
      warn_criteria => ['exit_status=0', 'max_age=49h'],
    }
  } else {
    sunet::scriptherder::cronjob { 'update_and_upgrade':
      ensure        => absent,
      cmd           => '/usr/local/sbin/silent-update-and-upgrade',
      purge_results => true,
    }
  }
}
