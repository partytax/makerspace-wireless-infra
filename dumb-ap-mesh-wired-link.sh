# Setup mesh nodes as dumb APs
# This script is tested on Archer C7 v2 devices

mac='f8ebf9'
ip='10.0.0.2'

# Install Mesh support package
opkg update
opkg remove wpad-basic-wolfssl
opkg install wpad-mesh-openssl
#

# Enable wifi
uci set wireless.@wifi-device[0].disabled=0
uci set wireless.@wifi-device[1].disabled=0
uci commit

# Rename wifi
uci set wireless.default_radio0.ssid='VS-5'
uci set wireless.default_radio1.ssid='VS-2'
uci commit

# ========================================================
# Setup a Dumb AP, Wired backbone for OpenWRT / LEDE
# ========================================================
echo 'setup dumb ap'
# Set lan logical interface as bridge (to allow bridge multiple physical interfaces)
uci set network.lan.type='bridge'
# assign WAN physical interface to LAN (will be available as an additional LAN port now)
#uci set network.lan.ifname="$(uci get network.lan.ifname) $(uci get network.wan.ifname)"
uci set network.lan.ifname="br-lan eth0.2"
uci del network.wan.ifname
# Remove wan logical interface, since we will not need it.
uci del network.wan

# Disable Dnsmasq completely (it is important to commit or discard dhcp)
# echo 'disable DHCP'
# uci commit dhcp; echo '' > /etc/config/dhcp
# /etc/init.d/dnsmasq disable
# /etc/init.d/dnsmasq stop

# Set static network configuration (sample config for 192.168.1.0/24)
# 10.0.0.1 is the Main Router
echo 'set static network conf'
uci set network.lan.ipaddr=$ip
uci set network.lan.dns='10.0.0.1'
uci set network.lan.gateway='10.1.10.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.broadcast='10.0.0.255'

# Set DHCP on LAN (not recommended, but useful when Dumb AP is moveable from one building to another)
# echo 'set DHCP on lan'
# uci del network.lan.broadcast
# uci del network.lan.dns
# uci del network.lan.gateway
# uci del network.lan.ipaddr
# uci del network.lan.netmask
# uci set network.lan.proto='dhcp'

# # To identify better when connected to SSH and when seen on the network
# echo 'rename host'
uci set system.@system[0].hostname=$mac
uci set network.lan.hostname="`uci get system.@system[0].hostname`"

# ========================================================
# Optional, Disable IPv6
# ========================================================
echo 'disable ipv6'
uci del network.lan.ip6assign
uci set network.lan.delegate='0'
uci del dhcp.lan.dhcpv6 # entry not found
uci del dhcp.lan.ra # not found
uci del dhcp.odhcpd # not found
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop 

# ========================================================
# Commit changes, flush, and restart network
# ========================================================
# This way we will get internet on this AP and we must reconnect
echo 'commit and reboot'
uci commit
sync
/etc/init.d/network restart
# If all is OK then reboot and test again:
reboot
