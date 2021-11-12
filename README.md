# How to build a makerspace wireless network

![three colorful gradients representing wireless network signal ranges](assets/colorful-networks.png)

Makerspaces require a wireless network that supports roaming users and communication with/between stationary workstations, servers, and devices.

Standard range extenders and access points are inadequate. They require roaming devices to disconnect from one AP, then connect to the next, usually with a delay. Mesh networks solve this problem, but most FLOSS mesh solutions are designed for use in larger communities (LibreMesh). In most community mesh setups, IP addresses are managed by each node and communication within the LAN is difficult.

The solution we've found is to run mesh nodes as dumb APs. This means that the nodes speak with one another, but all DHCP and DNS work is done by our main firewall. This is accomplished by running OpenWRT with mesh support and disabling DHCP on each mesh node.


## Hardware

### Bill of materials
* TP-Link Archer C7 v2
* Associated power supply
* Ethernet cable
* Computer with Linux operating system, web browser, and Ethernet port

### Instructions
* Connect device to power
* Connect Ethernet cable from device LAN port to computer Ethernet port

### Background information
Find basic info about the Archer C7 here:
https://openwrt.org/toh/tp-link/archer_c7

## Software

### Notes
The Archer C7-v2 doesn't seem to accept this version 21.02.0 firmware from OpenWRT:
`tplink_archer-c7-v2-squashfs-factory-us.bin	7011b53969441d886b1d25ba25a99018ac06246ae6fdf6badd1b302adcc21c3f	15872.0 KB	Thu Sep 2 03:50:37 2021`

It does however accept the version 19.07.8 firmware, followed by the version 21.02.0 sysupgrade.bin file.
* initial binary: `19.07.8: archer-c7-v2-squashfs-factory-us.bin	969b42b61e365e370fcfbab0450ff60a093e4cf3e587209b85a76f652ac4f300	15872.0 KB	Mon Aug 2 02:29:02 2021`
* upgrade binary: `21.02.0 upgrade: tplink_archer-c7-v2-squashfs-sysupgrade.bin	2665c3d169c276f08ecd1ea7d38f3d9bf9f32b7ecf424af89377f44889a26983	5504.3 KB	Thu Sep 2 03:50:37 2021`

### Instructions

#### Install OpenWRT
1. Start with TP-Link stock firmware 
1. Flash OpenWRT 19. Note that after flashing OpenWRT, the default IP is 192.168.1.1 . So if your IP is manually set to 192.168.0.1 from the TFTP process, it needs to be corrected in order to access the OpenWRT GUI.
1. Flash OpenWRT 21 sysupgrade

#### Configure OpenWRT
The instructions below detail the steps necessary to enable mesh networking on the router and disable DHCP. We have implemented most of this work in the `dumb-ap-mesh-wired-link.sh` script. This script can be uploaded to the router using `scp`, then executed on the router as a shell script.

##### Method A: Use script
1. `scp dumb-ap-mesh-wired-link.sh root@192.168.1.1:/tmp/dumb-ap-mesh-wired-link.sh`
1. `ssh root@192.168.1.1`
1. `cd /tmp`
1. `sh dumb-ap-mesh-wired-link.sh`

##### Method B: Use command line interface
1. `ssh root@192.168.1.1`
1. `opkg remove wpad-basic-wolfssl`
1. `opkg update`
1. `opkg install wpad-mesh-openssl`
1. Edit `/etc/config/wireless` and add the following interfaces:
```
config wifi-iface 'wifinet2'
        option device 'radio0'
        option mode 'mesh'    
        option encryption 'none'
        option mesh_fwding '1'  
        option mesh_rssi_threshold '0'
        option network 'lan'          
        option mesh_id 'vs-mesh5'
                                 
config wifi-iface 'wifinet3'
        option device 'radio1'
        option mode 'mesh'    
        option encryption 'none'
        option mesh_fwding '1'   
        option mesh_rssi_threshold '0'
        option network 'lan'   
        option mesh_id 'vs-mesh2'
```
**or** run these commands:
```
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio0'
uci set wireless.@wifi-iface[-1].mode='mesh'
uci set wireless.@wifi-iface[-1].encryption='none'
uci set wireless.@wifi-iface[-1].mesh_fwding='1'
uci set wireless.@wifi-iface[-1].mesh_rssi_threshold='0'
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mesh_id='vs-mesh5'

uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio1'
uci set wireless.@wifi-iface[-1].mode='mesh'
uci set wireless.@wifi-iface[-1].encryption='none'
uci set wireless.@wifi-iface[-1].mesh_fwding='1'
uci set wireless.@wifi-iface[-1].mesh_rssi_threshold='0'
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mesh_id='vs-mesh2'

uci commit

add wireless wifi-iface
set wireless.@wifi-iface[-1].ssid='example5'
set wireless.@wifi-iface[-1].device='radio1'
set wireless.@wifi-iface[-1].mode='ap'
set wireless.@wifi-iface[-1].encryption='psk2+ccmp'
set wireless.@wifi-iface[-1].key='example'
set wireless.@wifi-iface[-1].wps_pushbutton='0'
set wireless.@wifi-iface[-1].network='guest'


uci set wireless.wifinet3.encryption='sae'
uci set wireless.wifinet3.key='fourhundredtwo'
```

##### Method C: Use graphical web interface
1. Navigate to 192.168.1.1 in web browser
1. Uninstall wpad-basic-wolfssl under `System` --> `Software` (Router must have internet access through WAN port at this point)
1. Install wpad-mesh-openssl under `System` --> `Software`
1. `Networking` --> `Wireless` --> Add 2.4Ghz network
1. Change from AP to 802.11s
1. Attach to LAN
1. Give the mesh a name (we called ours `vs-mesh`)
1. Save and apply

#### Configure device as dumb AP
##### Notes
In order to disable dhcp and bridge networks, follow
https://openwrt.org/docs/guide-user/network/wifi/dumbap

##### Method A: Graphical web interface
- Disconnect the (soon-to-be) Dumb AP from your network, and connect your computer to it with an Ethernet cable.
- Use the web interface to go to Network → Interfaces and select the LAN interface.
- Enter an IP address “next to” your main router on the field “IPv4 address”. (If your main router has IP 192.168.1.1, enter 192.168.1.2). Set DNS and gateway to point into your main router to enable internet access for the dumb AP itself
- Then switch to “DHCP Server” tab (or scroll down in older versions, 18.06 and earlier, of Luci) and select the checkbox “Ignore interface: Disable DHCP for this interface.”
- Click “IPv6 Settings” tab and set everything to “disabled”.
- Under “Physical Settings” tab, ensure “Bridge interfaces” is ticked, and ensure BOTH of your interfaces (eth0, wlan0) are selected, in order to allow traffic between wireless and wired connections.
- In the top menu go to System → Startup, and disable firewall, dnsmasq and odhcpd in the list of startup scripts. It should be noted that even though they are disabled, flashing a new image to the device will re-enable them. One option is to add some code to /etc/rc.local to do this for you. See Disable Daemons Persistently.
- Click the Save and Apply button. Hard-Restart your router if you're not able to connect anymore.
- Go to http://192.168.1.2 (or whatever address you specified) and check if the settings for the LAN interface are the same.
- Use an Ethernet to connect one of the LAN ports on your main router to one of the LAN/switch ports of your “new” dumb AP. (There's no need to connect the WAN port of the Dumb AP.) Since neither the WAN nor WAN6 interfaces will be used, edit each one and uncheck 'bring up on boot' to disable them.
- You are done.

##### Method B: Command line interface
1. `wget https://gist.githubusercontent.com/braian87b/bba9da3a7ac23c35b7f1eecafecdd47d/raw/84d241cf30ca5545149d72b40fa16ab7a1e00373/dumb-ap-wired-link.sh`
1. `scp dumb-ap-wired-link.sh root@192.168.1.1:/tmp/dumb-ap-wired-link.sh`
1. `ssh root@192.168.1.1`
1. `cd /tmp`
1. `sh dumb-ap-wired-link.sh`

### Troubleshooting
So you've bricked your router? It's okay, we've done the same hundreds of times, and by the 100th time you fix it, you'll start to see that it's really not so difficult.

#### Try this first
If you've modified a config file and locked yourself out of the router, simply hold down the reset button for 15 seconds, then let go. This will reset back to the default configuration of whatever firmware is running.

If this does not work, move on to using TFTP.

#### TFTP Instructions for reinstalling TP-Link firmware
Firmware can be factory reset using TFTP.
1. plug PC into lan port of router
1. Manually set ethernet ipv4 ip to 192.168.0.66/24 (subnetmask 255.255.255.0) using the network manager
1. Ensure tftp server is running on PC.
1. Save TP-Link factory firmware to tftp server location (probably /tftp/) as ArcherC7v2_tp_recovery.bin
1. To start the TFTP recovery process on the router, press and hold the WPS/Reset Button and then power up the router. Keep the WPS/Reset button pressed until the WPS LED turns on (it's the LED with two arrows pointing in different directions), which is roughly 6 seconds.
1. The transfer takes place automatically, but to know if it's working, it helps to monitor the process.

##### Monitor TFTP traffic
Traffic can be monitored using tcpdump.
`sudo tcpdump port 69`

Below is an example of a successful recovery log.
```
root@madison:/home/vectorspace/Documents/mesh_routing/ArcherC7# sudo tcpdump port 69
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on experimental, link-type EN10MB (Ethernet), capture size 262144 bytes
11:25:25.285937 IP 192.168.0.86.3945 > madison.local.tftp:  45 RRQ "ArcherC7v2_tp_recovery.bin" octet timeout 3
```

### Our historical LibreMesh configuration
We ran LibreMesh for several years and were very happy with the performance, but frustrated in getting wifi connected machines to communicate with our servers for services such as LDAP authentication and NFS shares.

Below are our notes from when we used LibreMesh, as others may still find them valuable.

* [LibreMesh router firmware](https://libremesh.org)
    
#### Instructions for installing LibreMesh
* Use a web browser to navigate to 192.168.0.1
* Log into TP-Link web interface with:
    * Username: `admin`
    * Password: `admin`
* Download LibreMesh firmware for device from [https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin](https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin) (directory structure is navigable...we just picked the USA version).
* Update firmware in TP-Link interface, selecting downloaded LibreMesh firmware binary. May need to rename the firmware filename to a shorter name such as firmware.bin.
* Access libremesh admin interface by navigating browser to thisnode.info

