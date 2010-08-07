class openvpn::base { 
    package{'openvpn': 
        ensure => installed, 
    } 
 
    service{'openvpn': 
        ensure => running, 
        enable => true, 
        require => Package[openvpn], 
        hasstatus => true, 
        hasrestart => true, 
    } 
 
    file{'/etc/openvpn/server.conf': 
        source => [ "puppet:///modules/site-openvpn/${fqdn}/server.conf", 
                    "puppet:///modules/site-openvpn/server.conf", 
                    "puppet:///modules/openvpn/server.conf" ], 
        notify => Service[openvpn],  
        owner => root, group => 0, mode => 0600; 
    } 
 
    file{'/etc/openvpn/clients': 
        ensure => directory, 
        owner => root, group => 0, mode => 0755; 
    } 
}
