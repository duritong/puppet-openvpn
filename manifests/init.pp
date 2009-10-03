# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

class openvpn {
    case $operatingsystem {
        openbsd: { include openvpn::openbsd }
        default: { include openvpn::base }
    }
    if $use_munin {
        include openvpn::munin
    }
}
