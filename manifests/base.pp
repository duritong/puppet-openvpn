# setup openvpn
class openvpn::base {
  package{'openvpn':
    ensure => installed,
  } -> service{'openvpn':
    ensure  => running,
    enable  => true,
    require => Package['openvpn'],
  }

  $group = $osfamily ? {
    'Debian' => 'nogroup',
    default  => 'nobody',
  }

  if $osfamily == 'RedHat' {
    Service['openvpn']{
      name => 'openvpn@server'
    }
  }

  file{
    '/etc/openvpn':
      ensure  => directory,
      owner   => 'root',
      group   => $group,
      mode    => '0650',
      require => Package['openvpn'];
    '/etc/openvpn/server.conf':
      content => template('openvpn/server.conf.erb'),
      owner   => 'root',
      group   => 0,
      mode    => '0600',
      notify  => Service['openvpn'];
    '/etc/openvpn/clients':
      ensure  => directory,
      owner   => 'root',
      group   => $group,
      mode    => '0750',
      notify  => Service['openvpn'];
    '/etc/openvpn/req-config':
      content => template('openvpn/req-config.erb'),
      owner   => 'root',
      group   => 0,
      mode    => '0600';
  }

  if $openvpn::purge_clients {
    File['/etc/openvpn/clients']{
      purge   => true,
      force   => true,
      recurse => true,
    }
  }

  exec{
    'openvpn-generate-csr':
      command => "openssl req -batch -days ${openvpn::key_expire} -nodes -new -config /etc/openvpn/req-config -newkey rsa:${openvpn::key_size} -keyout /etc/openvpn/server.key -out /etc/openvpn/server.csr",
      creates => '/etc/openvpn/server.csr',
      require => File['/etc/openvpn/req-config'];
    'openvpn-generate-self-signed-cert':
      command => "openssl req -x509 -sha256 -days ${openvpn::key_expire} -key /etc/openvpn/server.key -in /etc/openvpn/server.csr -out /etc/openvpn/server.crt",
      creates => '/etc/openvpn/server.crt',
      require => Exec['openvpn-generate-csr'];
  }

  file{
    '/etc/openvpn/server.key':
      owner   => 'root',
      group   => 0,
      mode    => '0600',
      require => Exec['openvpn-generate-csr'];
  }
  # create those ahead of time with: "openssl dhparam -out dh.pem $key_size"
  certs::dhparams{'/etc/openvpn/dh.pem':
    require => File['/etc/openvpn'],
    notify  => Service['openvpn'],
  }
  if $openvpn::crl {
    file {
      '/etc/openvpn/crl.pem':
        source  => $openvpn::crl,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        notify  => Service['openvpn'],
        require => File['/etc/openvpn'];
    }
  }


  if $openvpn::ca_cert {
    file{'/etc/openvpn/ca.crt':
      source => $openvpn::ca_cert,
      owner  => 'root',
      group  => 0,
      mode   => '0600',
      notify => Service['openvpn'],
    }
  }
  # provide this file by signing '/etc/openvpn/server.csr' with your ca.
  if $openvpn::server_cert {
    file{'/etc/openvpn/server.crt':
      source  => $openvpn::server_cert,
      owner   => 'root',
      group   => 0,
      mode    => '0600',
      notify  => Service['openvpn'],
      require => Exec['openvpn-generate-self-signed-cert'];
    }
  }
}
