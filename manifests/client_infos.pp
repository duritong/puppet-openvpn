# set client specific infos
define openvpn::client_infos(
  $zone,
  $ensure       = 'present',
  $client_dir   = '/etc/openvpn/clients',
  $client_tool  = 'ifconfig-push',
  $client_ip    = undef,
  $server_ip    = undef,
) {
  $zone_conf = $openvpn::zones[$zone]
  $iroute = $zone_conf['route']
  $additional_config = $zone_conf['additional_config']
  $push_route = $zone_conf['push_route']
  if ($zone_conf['dns_server']) {
    $dns_server = $zone_conf['dns_server']
  } else {
    $dns_server = []
  }
  if ($zone_conf['dns_domain']) {
    $dns_domain = $zone_conf['dns_domain']
  } else {
    $dns_domain = []
  }

  file {
    "${client_dir}/${name}":
      notify  => Service['openvpn'],
  }
  if $ensure == 'present' {
    File["${client_dir}/${name}"]{
      content => template('openvpn/custom-client.conf.erb'),
      owner   => root,
      group   => $openvpn::group,
      mode    => '0640',
    }
  } else {
    File["${client_dir}/${name}"]{
      ensure => 'absent',
    }
  }
}
