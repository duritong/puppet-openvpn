class openvpn::base {
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
      content => template("openvpn/server.conf.erb"),
      owner   => root,
      group   => 0,
      mode    => 0600,
      notify  => Service[openvpn],
      require => File['/etc/openvpn'];
    '/etc/openvpn/clients':
      ensure  => directory,
      owner   => 'root',
      group   => 0,
      mode    => '0755',
      notify  => Service[openvpn],
      require => File['/etc/openvpn'];
    '/etc/openvpn/req-config':
      content => template('openvpn/req-config.erb'),
      require => File['/etc/openvpn'];
  }

  if $openvpn::crl {
    file {
      '/etc/openvpn/crl.pem':
        source  => ["puppet:///modules/site_openvpn/${::fqdn}/crl.pem",
                    "puppet:///modules/site_openvpn/${openvpn::group_name}/crl.pem",
                    "puppet:///modules/site_openvpn/crl.pem"],
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        notify  => Service[openvpn],
        require => File['/etc/openvpn'];
    }
  }

  exec{
    'generate-csr':
      command => "openssl req -batch -days $openvpn::key_expire -nodes -new \
-config /etc/openvpn/req-config -newkey rsa:$openvpn::key_size \
-keyout '/etc/openvpn/server.key' -out '/etc/openvpn/server.csr'",
      creates => "/etc/openvpn/server.csr",
      require => File['/etc/openvpn/req-config'];
  }

  file{
    # create those ahead of time with: "openssl dhparam -out dh.pem $key_size"
    '/etc/openvpn/dh.pem':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/dh.pem",
                  "puppet:///modules/site_openvpn/${openvpn::group_name}/dh.pem"],
      owner   => root,
      group   => 0,
      mode    => 0600,
      require => File['/etc/openvpn'];
    '/etc/openvpn/ca.crt':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/ca.crt",
                  "puppet:///modules/site_openvpn/${openvpn::group_name}/ca.crt",
                  "puppet:///modules/site_openvpn/ca.crt"],
      owner   => root,
      group   => 0,
      mode    => 0600,
      require => File['/etc/openvpn'];
    # provide this file by signing '/etc/openvpn/server.csr' with your ca.
    '/etc/openvpn/server.crt':
      source  => ["puppet:///modules/site_openvpn/${::fqdn}/server.crt"],
      owner   => root,
      group   => 0,
      mode    => 0600,
      notify  => Service[openvpn],
      require => Exec['generate-csr'];
    '/etc/openvpn/server.key':
      owner   => root,
      group   => 0,
      mode    => 0600,
      require => Exec['generate-csr'];
  }
}
