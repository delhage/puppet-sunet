class sunet::cgit::webserver(
  String $www_user = 'www-data',
  String $git_group = 'git',
) {
  sunet::apache2{'apache2 for cgit':}

  exec { 'let web user read git repos':
    command => "adduser $www_user $git_group",
  }

  exec { 'enable CGI':
    command => 'a2enmod cgi',
    notify  => Service['apache2'],
  }
}
