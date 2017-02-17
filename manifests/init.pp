# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

class openvpn (
  $key_country,
  $key_state,
  $key_locality,
  $key_organization,
  $key_organization_unit,
  $key_common_name,
  $key_email,
  $manage_munin           = false,
  $key_size               = 4096,
  $key_expire             = 365,
  $bind_address           = undef,
  $bind_port              = 1194,
  $protocol               = 'udp',
  $device_type            = 'tun',
  $local_net              = ['10.8.0.0', '24'],
  $push_route             = [],
  $push_default_gw        = false,
  $dns_server             = [],
  $dns_domain             = [],
  $comp_lzo               = false,
  $max_clients            = 100,
  $additional_config      = '',
  $zones                  = {},
  $crl                    = false,
  $group_name             = '',
  # This is tls1.2. See --show-tls for more options.
  $tls_cipher             = 'TLS-DHE-RSA-WITH-AES-256-GCM-SHA384',
  $cipher                 = 'AES-128-CBC',
  $masq_interface         = undef,
) {
  $local_netmask = cidr2netmask($local_net[1])

  case $::operatingsystem {
    openbsd: { include ::openvpn::openbsd }
    default: { include ::openvpn::base }
  }
  if $openvpn::manage_munin {
    include ::openvpn::munin
  }
}
