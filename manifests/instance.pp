define openvpn::instance (
  $ensure = 'present',
  $key_size = '4096',
) {
  if $ensure == 'present' {
    include openvpn

    exec{
      'build-dh':
        cwd      => '/etc/openvpn',
        command  => "/usr/bin/openssl dhparam -out dh.pem ${KEY_SIZE}",
        creates  => "/etc/openvpn/dh.pem",
        require  => Package[openvpn];
    }

    file{
      '/etc/openvpn/ca.crt':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/ca.crt",
                    "puppet:///modules/site_openvpn/ca.crt"],
        require => Package[openvpn];
      '/etc/openvpn/server.crt':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/server.crt"],
        require => Package[openvpn];
      '/etc/openvpn/server.key':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/server.key"],
        require => Package[openvpn];
    }
  }
}
