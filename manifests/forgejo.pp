class sunet::forgejo(
  String $domain          = 'platform.sunet.se',
  String $forgejo_version = '1.18.5-0-rootless',
  Integer $uid            = '900',
  Integer $gid            = '900',
){
  # gitea generate secret INTERNAL_TOKEN
  String $internal_token = hiera('internal_token')
  # gitea generate secret JWT_SECRET
  String $jwt_secret = hiera('jwt_secret')
  # gitea generate secret JWT_SECRET
  String $lfs_jwt_secret = hiera('lfs_jwt_secret')
  # gitea generate secret SECRET_KEY
  String $secret_key = hiera('secret_key')
  # Compose
  sunet::docker_compose { 'forgejo':
    content          => template('sunet/forgejo/docker-compose.yaml.erb'),
    service_name     => 'forgejo',
    compose_dir      => '/opt',
    compose_filename => 'docker-compose.yaml',
    description      => 'Forgejo Git Services',
  }
  -> 'sunet::misc':system_user {
    username => 'git',
    group    => 'git',
    uid      => $uid,
    gid      => $gid,
  }
  # Data directory
  -> file{ '/opt/forgejo/data':
    ensure => directory;
    owner => 'git'
    group => 'git'
  }
  # Config directory/file
  -> file{ '/opt/forgejo/config':
    ensure => directory;
    owner => 'git'
    group => 'git'
  }
  -> file{ '/opt/forgejo/config/app.ini':
    ensure  => file,
    content => template('forgejo/app.ini.erb'),
    mode    => '0644',
    owner   => 'git',
    group   => 'git'
  }
}
