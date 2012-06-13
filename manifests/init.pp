# openvpn/manifests/init.pp - manage openvpn stuff
# Copyright (C) 2007 admin@immerda.ch
# GPLv3

class openvpn (
  $manage_munin => false
) {
  case $::operatingsystem {
    openbsd: { include openvpn::openbsd }
    default: { include openvpn::base }
  }
  if $openvpn::manage_munin {
    include openvpn::munin
  }
}
