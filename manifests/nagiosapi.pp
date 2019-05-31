require stdlib

# TODO: enable the RW functions of the API at some point - need to mount nagios.cmd if exists
# TODO: add tls frontend

class sunet::nagiosapi($version='latest',$api_port=5667) {

   $nagios_ip_v4 = hiera('nagios_ip_v4', '109.105.111.111')
   $nagios_ip_v6 = hiera('nagios_ip_v6', '2001:948:4:6::111')
   $api_clients  = hiera_array('nagios_api_clients',['127.0.0.1','127.0.1.1',$nagios_ip_v4,$nagios_ip_v6])

   sunet::docker_run {'nagios-api':
      image    => 'docker.sunet.se/nagios-api',
      imagetag => $version,
      volumes  => ['/var/cache/nagios3/status.dat:/var/cache/nagios3/status.dat:ro',
                   '/var/log/nagios3/nagios.log:/var/log/nagios3/nagios.log:ro'],
      ports    => ["$api_port:8080"]
   }

   $api_clients.each |$client| {
      $client_name = regsubst($client,'([.:]+)','_','G')
      ufw::allow { "allow-nagios-api-${client_name}":
         from  => "${client}",
         ip    => 'any',
         proto => 'tcp',
         port  => "$api_port",
      }
   }
}
