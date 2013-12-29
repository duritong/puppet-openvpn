define openvpn::client_infos(
  $client_dir = '/etc/openvpn/clients',
  $client_tool = 'ifconfig-push',
  $client_ip = undef,
  $server_ip = undef,
  $zone
) {
  $zone_conf = $openvpn::zones[$zone]
  $iroute = $zone_conf['route']
  $additional_config = $zone_conf['additional_config']
  $push_route = $zone_conf['push_route']
  $dns_server = $zone_conf['dns_server']

  if $push_route == 'undef' {
    $push_route = []
  }

  if $dns_server == 'undef' {
    $dns_server = []
  }

  file{
    "${client_dir}/${name}":
      content => template("openvpn/custom-client.conf.erb"),
      owner   => root,
      group   => 0,
      mode    => 0600,
      notify  => Service[openvpn],
      require => File['/etc/openvpn'];
  }
}
