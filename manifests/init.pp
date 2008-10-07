# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

import 'defines.pp'

class openvpn {
    case $operatingsystem {
        openbsd: { include openvpn::openbsd }
        default: { include openvpn::base }
    }
    if $use_munin {
        include openvpn::munin
    }
}

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
        source => [ "puppet://$server/files/openvpn/${fqdn}/server.conf",
                    "puppet://$server/files/openvpn/server.conf",
                    "puppet://$server/openvpn/server.conf" ],
        notify => Service[openvpn], 
        owner => root, group => 0, mode => 0600;
    }

    file{'/etc/openvpn/clients':
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
}

class openvpn::openbsd inherits openvpn::base {
    Service[openvpn]{
        hasrestart => false,
        hasstatus => false,
        start => '/usr/local/sbin/openvpn /etc/openvpn/server.conf',
        restart => "kill -HUP `ps ax | grep /usr/sbin/sshd | grep -v grep | awk '{print $1}'`",
        stop => "kill `ps ax | grep /usr/sbin/sshd | grep -v grep | awk '{print $1}'`",
    }

    openbsd::add_to_rc_local{'openvpn':
        binary => '/etc/openvpn/server.conf',
        test_op => '-f',
        start_cmd => '/usr/local/sbin/openvpn /etc/openvpn/server.conf',
    }

}
