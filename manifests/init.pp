# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

class openvpn (
  $key_country            = 'CH',
  $key_state              = 'Be',
  $key_locality           = 'Be',
  $key_organization       = $domain,
  $key_organization_unit  = $domain,
  $key_email              = "root@${domain}",
  $key_common_name        = $fqdn,
  $manage_munin           = false,
  $manage_shorewall       = false,
  $key_size               = 4096,
  $key_expire             = 365,
  $bind_address           = false,
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
  $ca_cert                = '/var/lib/puppet/ssl/certs/ca.pem',
  $server_cert            = false,
  $group_name             = '',
  # This is tls1.2. See --show-tls for more options.
  $tls_cipher             = 'TLS-DHE-RSA-WITH-AES-256-GCM-SHA384',
  $cipher                 = 'AES-128-CBC',
  $masq_interface         = undef,
  $clients                = {},
  $purge_clients          = true,
) {
  $local_netmask = cidr2netmask($local_net[1])

  case $::operatingsystem {
    default: { include ::openvpn::base }
  }
  if $openvpn::manage_munin {
    include ::openvpn::munin
  }
  if $openvpn::manage_shorewall {
    include shorewall::rules::openvpn
    shorewall::interface { 'tun0':
      zone    => 'vpn',
      rfc1918 => true,
      options => 'routeback,logmartians';
    }
    if $masq_interface {
      shorewall::masq{'openvpn':
        interface => $masq_interface,
        source    => "${local_net[0]}/${local_net[1]}",
      }
    }
  }
  create_resources(openvpn::client_infos, $clients)
}
