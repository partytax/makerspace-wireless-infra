# How to build a makerspace wireless network

![three colorful gradients representing wireless network signal ranges](assets/colorful-networks.png)

## Hardware

### Bill of materials
* TP-Link Archer C7 v2
* Associated power supply
* Ethernet cable
* Computer with Linux operating system, web browser, and Ethernet port

### Instructions
* Connect device to power
* Connect Ethernet cable from device LAN port to computer Ethernet port

### Background Info
Find basic info about the Archer C7 here:
https://openwrt.org/toh/tp-link/archer_c7

## Software

### Bill of materials
* [LibreMesh router firmware](https://libremesh.org)
    
### Instructions for installing LibreMesh
* Use a web browser to navigate to 192.168.0.1
* Log into TP-Link web interface with:
    * Username: `admin`
    * Password: `admin`
* Download LibreMesh firmware for device from [https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin](https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin) (directory structure is navigable...we just picked the USA version).
* Update firmware in TP-Link interface, selecting downloaded LibreMesh firmware binary. May need to rename the firmware filename to a shorter name such as firmware.bin.
* Access libremesh admin interface by navigating browser to thisnode.info



### Instructions for reinstalling TP-Link firmware
Firmware can be factory reset using TFTP.

- plug PC into lan port
- Manually set ethernet ipv4 ip to 192.168.0.66/24 (subnetmask 255.255.255.0) using the network manager
- To start the TFTP recovery process on the router, press and hold the WPS/Reset Button and then power up the router. Keep the WPS/Reset button pressed until the WPS LED turns on (it's the LED with two arrows pointing in different directions), which is roughly 6 seconds.

#### Monitor TFTP traffic
Traffic can be monitored using tcpdump.

$ sudo tcpdump port 69

Below is an example of a successful recovery log.

root@madison:/home/vectorspace/Documents/mesh_routing/ArcherC7# sudo tcpdump port 69
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on experimental, link-type EN10MB (Ethernet), capture size 262144 bytes
11:25:25.285937 IP 192.168.0.86.3945 > madison.local.tftp:  45 RRQ "ArcherC7v2_tp_recovery.bin" octet timeout 3
