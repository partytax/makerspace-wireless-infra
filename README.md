# How to build a makerspace wireless network

![three colorful gradients representing wireless network signal ranges](assets/colorful-networks.png)

## Hardware

### Bill of materials
* TP-Link Archer C7 v2
* Associate power supply
* Ethernet cable
* Computer with Linux operating system, web browser, and Ethernet port

### Instructions
* Connect device to power
* Connect Ethernet cable from device LAN port to computer Ethernet port


## Software

### Bill of materials
* [LibreMesh router firmware](https://libremesh.org)
    
### Instructions for installing LibreMesh
* Use a web browser to navigate to 192.168.0.1
* Log into TP-Link web interface with:
    * Username: `admin`
    * Password: `admin`
* Download LibreMesh firmware for device from [https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin](https://downloads.libremesh.org/dayboot_rely/17.06/targets/ar71xx/generic/archer-c7-v2/lime_default/lede-17.01.2-lime-default-ar71xx-generic-archer-c7-v2-squashfs-factory-us.bin) (directory structure is navigable...we just picked the USA version).
* Update firmware in TP-Link interface, selecting downloaded LibreMesh firmware binary

### Instructions for reinstalling TP-Link firmware
* Not implemented (something involving TFTP)
