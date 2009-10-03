class openvpn::openbsd inherits openvpn::base {
    Service[openvpn]{
        hasrestart => false,
        hasstatus => false,
        start => 'cd /etc/openvpn/; /usr/local/sbin/openvpn --daemon --config /etc/openvpn/server.conf',
        restart => "kill -HUP `ps ax | grep /usr/local/sbin/openvpn | grep -v grep | awk '{print $1}'`",
        stop => "kill `ps ax | grep /usr/local/sbin/openvpn | grep -v grep | awk '{print $1}'`",
    }

    openbsd::rc_local{'openvpn':
        binary => '/etc/openvpn/server.conf',
        test_op => '-f',
        start_cmd => 'cd /etc/openvpn/; /usr/local/sbin/openvpn --daemon --config /etc/openvpn/server.conf',
    }

}
