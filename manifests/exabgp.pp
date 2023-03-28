# Old manifest for running exabgp. Look in manifests/exabgp/ instead.
define sunet::exabgp(
  Array   $extra_arguments = [],
  String  $config          = '/etc/bgp/exabgp.conf',
  String  $version         = 'latest',
  String  $volume          = '/etc/bgp',
  Array   $docker_volumes  = [],
) {
  $safe_title = regsubst($title, '[^0-9A-Za-z.\-]', '-', 'G');

  sunet::exabgp::docker_run { $name :
      image    => 'docker.sunet.se/sunet/docker-sunet-exabgp',
      imagetag => $version,
      volumes  => flatten(["${volume}:${volume}:ro", $docker_volumes]),
      net      => 'host',
      command  => join(flatten([$config, $extra_arguments]),' ')
  }

  sunet::snippets::no_icmp_redirects {"no_icmp_redirects_${safe_title}": }

  sunet::exabgp::molly_guard { $name :
    service_name => "docker-${safe_title}_exabgp",
  }
}
