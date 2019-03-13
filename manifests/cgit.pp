class sunet::cgit(
  String $fqdn,
  String $package       = 'cgit',
  String $cgitrepo_path = '/home/git/repositories/',
  String $www_user      = 'www-data',
  String $git_group     = 'git',
) {
  exec { 'let web user read git repos':
    command => "adduser $www_user $git_group",
  }

  exec { 'disable 000-default':
    command => 'a2dissite 000-default',
    onlyif  => 'test -L /etc/apache2/sites-enabled/000-default.conf',
    notify  => Service['apache2'],
  }

  exec { 'enable CGI':
    command => 'a2enmod cgid',
    creates => '/etc/apache2/mods-enabled/cgid.load',
    notify  => Service['apache2'],
  }

  file { '/etc/cgitrc':
    content => template('sunet/cgit/cgitrc.erb'),
  }

  file { '/etc/apache2/sites-available/010-cgit.conf':
    content => template('sunet/cgit/apache2-siteconf.erb'),
  }

  exec { 'enable 010-cgit':
    command => 'a2ensite 010-cgit',
    creates => '/etc/apache2/sites-enabled/010-cgit.conf',
    onlyif  => 'test -s /etc/ssl/certs/git-prod-1.sunet.se.crt',
    notify  => Service['apache2'],
  }
}
