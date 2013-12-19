define openvpn::instance (
  $ensure = 'present',
  $key_size = '4096',
) {
  if $ensure == 'present' {
    include openvpn

    file{
      '/etc/openvpn/ca.crt':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/ca.crt",
                    "puppet:///modules/site_openvpn/ca.crt"],
        require => Package[openvpn];
      '/etc/openvpn/dh.pem':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/dh.pem"],
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
