class openvpn::base (
  $key_size = 4096,
  $key_expire = 365,
  $key_country,
  $key_state,
  $key_locality,
  $key_organization,
  $key_organization_unit,
  $key_common_name,
  $key_email
) {
  package{'openvpn':
    ensure => installed,
  }

  service{'openvpn':
    ensure     => running,
    enable     => true,
    require    => Package[openvpn],
    hasstatus  => true,
    hasrestart => true,
  }

  file{
    '/etc/openvpn':
      ensure  => directory,
      require => Package[openvpn];
    '/etc/openvpn/server.conf':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/server.conf",
                  "puppet:///modules/site_openvpn/server.conf",
                  "puppet:///modules/openvpn/server.conf"],
      owner   => root,
      group   => 0,
      mode    => 0600,
      notify  => Service[openvpn],
      require => File['/etc/openvpn'];
    '/etc/openvpn/clients':
      ensure  => directory,
      owner   => 'root',
      group   => 0,
      mode    => 0755,
      notify  => Service[openvpn],
      require => File['/etc/openvpn'];
    '/etc/openvpn/req-config':
      content => template('openvpn/req-config.erb'),
      require => File['/etc/openvpn'];
  }

  exec{
    'generate-csr':
      command  => "openssl req -days $key_expire -nodes -new \
-config /etc/openvpn/req-config -newkey rsa:$key_size \
-keyout '/etc/openvpn/server.key' -out '/etc/openvpn/server.csr'",
      creates  => "/etc/openvpn/server.key",
      requires => File['/etc/openvpn/req-config'];
  }

  file{
    #create those ahead of time with: "openssl dhparam -out dh.pem $key_size"
    '/etc/openvpn/dh.pem':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/dh.pem"],
      require => File['/etc/openvpn'];
    '/etc/openvpn/ca.crt':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/ca.crt",
                  "puppet:///modules/site_openvpn/ca.crt"],
      require => File['/etc/openvpn'];
    '/etc/openvpn/server.crt':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/server.crt"],
      require => Exec['generate-csr'];
  }
}
