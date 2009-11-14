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
        source => [ "puppet://$server/modules/site-openvpn/${fqdn}/server.conf", 
                    "puppet://$server/modules/site-openvpn/server.conf", 
                    "puppet://$server/modules/openvpn/server.conf" ], 
        notify => Service[openvpn],  
        owner => root, group => 0, mode => 0600; 
    } 
 
    file{'/etc/openvpn/clients': 
        ensure => directory, 
        owner => root, group => 0, mode => 0755; 
    } 
}
