# manifests/munin.pp

class openvpn::munin {
    munin::plugin::deploy { 'openvpn_clients':
        source => 'openvpn/munin/openvpn_clients',
        config => 'user root',
    }
}
