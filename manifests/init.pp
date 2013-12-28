# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

class openvpn (
  $manage_munin = false,
  $key_size = 4096,
  $key_expire = 365,
  $key_country,
  $key_state,
  $key_locality,
  $key_organization,
  $key_organization_unit,
  $key_common_name,
  $key_email,
  $bind_address = undef,
  $bind_port = 1194,
  $protocol = 'udp',
  $device_type = 'tun',
  $local_net = ['10.8.0.0', '255.255.255.0'],
  $push_route = [],
  $push_default_gw = false,
  $dns_server = [],
  $comp_lzo = false,
  $max_clients = 100,
  $additional_config
) {
  $local_netmask = cidr2netmask($local_net[1])

  case $::operatingsystem {
    openbsd: { include openvpn::openbsd }
    default: { include openvpn::base }
  }
  if $openvpn::manage_munin {
    include openvpn::munin
  }
}
